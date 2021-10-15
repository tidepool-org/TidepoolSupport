//
//  TidepoolSupport.swift
//  TidepoolSupport
//
//  Created by Rick Pasetto on 10/11/21.
//
//

import os.log
import LoopKit
import LoopKitUI
import TidepoolKit
import SwiftUI

public final class TidepoolSupport: SupportUI, TAPIObserver {
    public typealias RawStateValue = [String: Any]

    public static let supportIdentifier = "TidepoolSupport"

    public let tapi: TAPI
    private var environment: TEnvironment?
    
    private let appStoreVersionChecker = AppStoreVersionChecker()

    public private (set) var error: Error?

    private var lastVersionInfo: VersionInfo?
    public var lastVersionCheckAlertDate: Date?

    public weak var alertIssuer: AlertIssuer?
    
    private let log = OSLog(category: supportIdentifier)

    public init(_ environment: TEnvironment? = nil) {
        tapi = TAPI()
        
        self.environment = environment ?? UserDefaults.appGroup?.tidepoolEnvironmentConfig
             
        tapi.addObserver(self)
    }

    deinit {
        tapi.removeObserver(self)
    }

    public convenience init?(rawState: RawStateValue) {
        self.init()
        self.lastVersionInfo = (rawState["lastVersionInfo"] as? String).flatMap { VersionInfo(from: $0) }
        self.lastVersionCheckAlertDate = rawState["lastVersionCheckAlertDate"] as? Date
    }

    public var rawState: RawStateValue {
        var rawValue: RawStateValue = [:]
        rawValue["lastVersionInfo"] = lastVersionInfo?.toJSON()
        rawValue["lastVersionCheckAlertDate"] = lastVersionCheckAlertDate
        return rawValue
    }

    public func apiDidUpdateSession(_ session: TSession?) {
        // noop
    }
}

extension TidepoolSupport {

    public func checkVersion(bundleIdentifier: String, currentVersion: String, completion: @escaping (Result<VersionUpdate?, Swift.Error>) -> Void) {
        
        let group = DispatchGroup()
        var infoResult: Result<VersionUpdate?, Swift.Error>!
        var appStoreResult: Result<VersionUpdate?, Swift.Error>!
        
        group.enter()
        checkVersionInfo(bundleIdentifier: bundleIdentifier, currentVersion: currentVersion) {
            infoResult = $0
            group.leave()
        }
        
        group.enter()
        appStoreVersionChecker.checkVersion(bundleIdentifier: bundleIdentifier, currentVersion: currentVersion) {
            appStoreResult = $0
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.global(qos: .background)) { [weak self] in
            var alertVersion: VersionUpdate? = nil
            var completionResult: Result<VersionUpdate?, Swift.Error>
            switch (infoResult!, appStoreResult!) {
            case (.failure, .failure):
                completionResult = infoResult
            case (.failure(let error), .success(let appStoreVersion)):
                self?.log.error("Tidepool info checkVersion failed: %@", error.localizedDescription)
                completionResult = .success(appStoreVersion)
            case (.success(let infoVersion), .failure):
                alertVersion = infoVersion
                completionResult = infoResult
            case (.success(let infoVersionOptional), .success(let appStoreVersionOptional)):
                switch (infoVersionOptional, appStoreVersionOptional) {
                case (nil, nil):
                    completionResult = .success(nil)
                case (nil, .some(let appStoreVersion)):
                    alertVersion = appStoreVersion
                    completionResult = .success(appStoreVersion)
                case (.some(let infoVersion), nil):
                    alertVersion = infoVersion
                    completionResult = .success(infoVersion)
                case (.some(let infoVersion), .some(let appStoreVersion)):
                    alertVersion = max(infoVersion, appStoreVersion)
                    completionResult = .success(alertVersion)
                }
            }
            if let alertVersion = alertVersion {
                self?.maybeIssueAlert(alertVersion)
            }
            completion(completionResult)
        }
    }
    
    public func checkVersionInfo(bundleIdentifier: String, currentVersion: String, completion: @escaping (Result<VersionUpdate?, Swift.Error>) -> Void) {
        // TODO: ideally the backend API takes `bundleIdentifier` as a parameter, instead of returning a big struct
        // with all version info (which we parse below)
        // Note also that this will use the _default environment_ unless the user switches environments and logs in.
        tapi.getInfo(environment: environment) { [weak self] result in
            switch result {
            case .failure(let error):
                // If an error or timeout occurs, respond with the last-known version info, otherwise, reply with an error
                if let versionInfo = self?.lastVersionInfo {
                    self?.log.error("checkVersion error: %{public}@ Returning %{public}@",
                                    error.localizedDescription,
                                    versionInfo.getVersionUpdateNeeded(currentVersion: currentVersion).localizedDescription)
                    completion(.success(versionInfo.getVersionUpdateNeeded(currentVersion: currentVersion)))
                } else {
                    self?.log.error("checkVersion error: %{public}@", error.localizedDescription)
                    completion(.failure(error))
                }
            case .success(let info):
                self?.log.debug("checkVersion info = %{public}@ for %{public}@ version %{public}@", info.versions.debugDescription, bundleIdentifier, currentVersion)
                let versionInfo = info.versions?.loop.flatMap { VersionInfo(bundleIdentifier: bundleIdentifier, loop: $0) }
                self?.lastVersionInfo = versionInfo
                completion(.success(versionInfo?.getVersionUpdateNeeded(currentVersion: currentVersion)))
            }
        }
    }
}

extension TidepoolSupport {
    
    private static var alertCadence = TimeInterval(2 * 7 * 24 * 60 * 60) // every 2 weeks
    
    public func setAlertIssuer(alertIssuer: AlertIssuer?) {
        self.alertIssuer = alertIssuer
    }
    
    public func softwareUpdateView(guidanceColors: GuidanceColors,
                                   bundleIdentifier: String,
                                   currentVersion: String,
                                   openAppStoreHook: (() -> Void)?) -> AnyView? {
        let viewModel = SoftwareUpdateViewModel(support: self, guidanceColors: guidanceColors, bundleIdentifier: bundleIdentifier, currentVersion: currentVersion)
        return AnyView(SoftwareUpdateView(softwareUpdateViewModel: viewModel))
    }
    
    private func maybeIssueAlert(_ versionUpdate: VersionUpdate) {
        guard versionUpdate >= .recommended else {
            noAlertNecessary()
            return
        }
        
        let alertIdentifier = Alert.Identifier(managerIdentifier: Self.supportIdentifier, alertIdentifier: versionUpdate.rawValue)
        let alertContent: LoopKit.Alert.Content
        if firstAlert {
            alertContent = Alert.Content(title: versionUpdate.localizedDescription,
                                         body: NSLocalizedString("""
                                                    Your Tidepool Loop app is out of date. It will continue to work, but we recommend updating to the latest version.
                                                    
                                                    Go to Tidepool Loop Settings > Software Update to complete.
                                                    """, comment: "Alert content body for first software update alert"),
                                         acknowledgeActionButtonLabel: NSLocalizedString("OK", comment: "default acknowledgement"),
                                         isCritical: versionUpdate == .required)
        } else if let lastVersionCheckAlertDate = lastVersionCheckAlertDate,
                  abs(lastVersionCheckAlertDate.timeIntervalSinceNow) > Self.alertCadence {
            alertContent = Alert.Content(title: NSLocalizedString("Update Reminder", comment: "Recurring software update alert title"),
                                         body: NSLocalizedString("""
                                                    A software update is recommended to continue using the Tidepool Loop app.
                                                    
                                                    Go to Tidepool Loop Settings > Software Update to install the latest version.
                                                    """, comment: "Alert content body for recurring software update alert"),
                                         acknowledgeActionButtonLabel: NSLocalizedString("OK", comment: "default acknowledgement"),
                                         isCritical: versionUpdate == .required)
        } else {
            return
        }
        alertIssuer?.issueAlert(Alert(identifier: alertIdentifier, foregroundContent: alertContent, backgroundContent: alertContent, trigger: .immediate))
        recordLastAlertDate()
    }
    
    private func noAlertNecessary() {
        lastVersionCheckAlertDate = nil
    }
    
    private var firstAlert: Bool {
        return lastVersionCheckAlertDate == nil
    }
    
    private func recordLastAlertDate() {
        lastVersionCheckAlertDate = Date()
    }
    
}

extension TidepoolSupport  {

    public func supportMenuItem(supportInfoProvider: SupportInfoProvider, urlHandler: @escaping (URL) -> Void) -> AnyView? {
        let viewModel = AdverseEventReportViewModel(supportInfoProvider: supportInfoProvider)
        return AnyView(AdverseEventReportButton(adverseEventReportViewModel: viewModel, urlHandler: urlHandler))
    }
}

extension UserDefaults {
    // HACK: hard coded app group!
    static let appGroup = UserDefaults(suiteName: "group.org.tidepool.LoopGroup")
    
    var tidepoolEnvironmentConfig: TEnvironment? {
        guard let val = string(forKey: "org.tidepool.Loop.TidepoolEnvironment"),
              let env = try? JSONDecoder().decode(TEnvironment.self, from: val.data(using: .utf8)!) else {
                  return nil
              }
        return env
    }
}
