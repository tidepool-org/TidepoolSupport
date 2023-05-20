//
//  TidepoolSupport.swift
//  TidepoolSupport
//
//  Created by Rick Pasetto on 10/11/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import os.log
import LoopKit
import LoopKitUI
import TidepoolKit
import TidepoolServiceKit
import SwiftUI

public final class TidepoolSupport: SupportUI, TAPIObserver {

    public typealias RawStateValue = [String: Any]

    public static let supportIdentifier = "TidepoolSupport"

    public var tapi: TAPI?
    private var environment: TEnvironment?

    private let appStoreVersionChecker = AppStoreVersionChecker()

    public private (set) var error: Error?

    private var lastVersionInfo: VersionInfo?
    public var lastVersionCheckAlertDate: Date?

    public weak var delegate: SupportUIDelegate?
    
    private var alertIssuer: AlertIssuer? { return delegate }
    
    private let log = OSLog(category: supportIdentifier)

    public init(tapi: TAPI? = nil, environment: TEnvironment? = nil) {
        self.tapi = tapi
        self.environment = environment
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

    public func initializationComplete(for services: [LoopKit.Service]) {
        if let tidepoolService = services.first(where: { $0 as? TidepoolService != nil }) as? TidepoolService {
            self.tapi = tidepoolService.tapi
            Task {
                if let session = await tapi?.session {
                    environment = session.environment
                }
            }
        }
    }

    public func apiDidUpdateSession(_ session: TSession?) {
        // noop
    }

    public func configurationMenuItems() -> [AnyView] {
        return []
    }

    private var _studyProductSelection: String?
}

extension TidepoolSupport {

    public func checkVersion(bundleIdentifier: String, currentVersion: String) async -> VersionUpdate? {

        async let infoVersionOptional = checkVersionInfo(bundleIdentifier: bundleIdentifier, currentVersion: currentVersion)
        async let appStoreVersionOptional = appStoreVersionChecker.checkVersion(bundleIdentifier: bundleIdentifier, currentVersion: currentVersion)

        let result: VersionUpdate? = [await infoVersionOptional, await appStoreVersionOptional].reduce(nil) { (a, b) in
            if let a, let b {
                return max(a, b)
            } else {
                return a ?? b
            }
        }

        if let alertVersion = result {
            maybeIssueAlert(alertVersion)
        }
        return result
    }
    
    public func checkVersionInfo(bundleIdentifier: String, currentVersion: String) async -> VersionUpdate? {
        // TODO: ideally the backend API takes `bundleIdentifier` as a parameter, instead of returning a big struct
        // with all version info (which we parse below).  See https://tidepool.atlassian.net/browse/BACK-2012

        do {
            if let tapi {
                let defaultEnvironment = tapi.defaultEnvironment
                let sessionEnvironment = await tapi.session?.environment
                let environment = environment ?? sessionEnvironment ?? defaultEnvironment ?? TEnvironment.productionEnvironment
                let info = try await tapi.getInfo(environment: environment)
                log.debug("checkVersion info = %{public}@ for %{public}@ version %{public}@", info.versions.debugDescription, bundleIdentifier, currentVersion)
                let versionInfo = info.versions?.loop.flatMap { VersionInfo(bundleIdentifier: bundleIdentifier, loop: $0) }
                lastVersionInfo = versionInfo
                return versionInfo?.getVersionUpdateNeeded(currentVersion: currentVersion)
            } else {
                throw TError.sessionMissing
            }
        } catch {
            // If an error or timeout occurs, respond with the last-known version info, otherwise, reply with an error
            if let versionInfo = lastVersionInfo {
                log.error("checkVersion error: %{public}@; Returning %{public}@",
                                error.localizedDescription,
                                versionInfo.getVersionUpdateNeeded(currentVersion: currentVersion).localizedDescription)
                return versionInfo.getVersionUpdateNeeded(currentVersion: currentVersion)
            } else {
                log.error("checkVersion error: %{public}@", error.localizedDescription)
                return nil
            }
        }
    }
}

extension TidepoolSupport {
    
    private static var alertCadence = TimeInterval(7 * 24 * 60 * 60) // every 7 days
        
    public func softwareUpdateView(bundleIdentifier: String,
                                   currentVersion: String,
                                   guidanceColors: GuidanceColors,
                                   openAppStore: (() -> Void)?) -> AnyView? {
        let viewModel = SoftwareUpdateViewModel(support: self,
                                                guidanceColors: guidanceColors,
                                                openAppStore: openAppStore,
                                                bundleIdentifier: bundleIdentifier,
                                                currentVersion: currentVersion)
        return AnyView(SoftwareUpdateView(softwareUpdateViewModel: viewModel))
    }
    
    private func maybeIssueAlert(_ versionUpdate: VersionUpdate) {
        guard versionUpdate >= .recommended else {
            noAlertNecessary(versionUpdate)
            return
        }
        
        let alertIdentifier = Alert.Identifier(managerIdentifier: Self.supportIdentifier, alertIdentifier: versionUpdate.rawValue)
        let alertContent: LoopKit.Alert.Content
        if firstAlert {
            alertContent = Alert.Content(title: versionUpdate.localizedDescription,
                                         body: LocalizedString("""
                                                    Your Tidepool Loop app is out of date. It will continue to work, but we recommend updating to the latest version.
                                                    
                                                    Go to Tidepool Loop Settings > Software Update to complete.
                                                    """, comment: "Alert content body for first software update alert"),
                                         acknowledgeActionButtonLabel: LocalizedString("OK", comment: "Default acknowledgement"))
        } else if let lastVersionCheckAlertDate = lastVersionCheckAlertDate,
                  abs(lastVersionCheckAlertDate.timeIntervalSinceNow) > Self.alertCadence {
            alertContent = Alert.Content(title: LocalizedString("Update Reminder", comment: "Recurring software update alert title"),
                                         body: LocalizedString("""
                                                    A software update is recommended to continue using the Tidepool Loop app.
                                                    
                                                    Go to Tidepool Loop Settings > Software Update to install the latest version.
                                                    """, comment: "Alert content body for recurring software update alert"),
                                         acknowledgeActionButtonLabel: LocalizedString("OK", comment: "Default acknowledgement"))
        } else {
            return
        }
        let interruptionLevel: LoopKit.Alert.InterruptionLevel = versionUpdate == .required ? .critical : .active
        alertIssuer?.issueAlert(Alert(identifier: alertIdentifier, foregroundContent: alertContent, backgroundContent: alertContent, trigger: .immediate, interruptionLevel: interruptionLevel))
        recordLastAlertDate()
    }
    
    private func noAlertNecessary(_ versionUpdate: VersionUpdate) {
        let alertIdentifier = Alert.Identifier(managerIdentifier: Self.supportIdentifier, alertIdentifier: versionUpdate.rawValue)
        alertIssuer?.retractAlert(identifier: alertIdentifier)
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
    public func configurationMenuItems() -> [LoopKitUI.CustomMenuItem] {
        var menuItems = [LoopKitUI.CustomMenuItem]()
        if let delegate {
            let viewModel = AdverseEventReportViewModel(supportInfoProvider: delegate)
            let view = AdverseEventReportButton(adverseEventReportViewModel: viewModel) { url in
                delegate.openURL(url: url)
            }
            menuItems.append(CustomMenuItem(section: .support, view: AnyView(view)))
        }
        if let tapi {
            menuItems.append(
                CustomMenuItem(
                    section: .custom(localizedTitle: LocalizedString("Share Activity", comment: "Settings menu section title for share activity")),
                    view: AnyView(myCaregiversMenu(api: tapi))))
        }
        return menuItems
    }

    func myCaregiversMenu(api: TAPI) -> some View {
        NavigationLink("My Caregivers") {
            MyCaregiversView(caregiverManager: CaregiverManager(caregivers: [], api: api))
        }
    }
}

extension TidepoolSupport {
    public enum StudyProduct: String {
        case none
        case studyProduct1
        case studyProduct2
    }
    
    public var studyProduct: StudyProduct {
        StudyProduct(rawValue: UserDefaults.appGroup?.studyProductSelection ?? "none") ?? .none
    }
    
    public func getScenarios(from scenarioURLs: [URL]) -> [LoopScenario] {
        var filteredURLs: [URL] = []

        switch studyProduct {
        case .none:
            filteredURLs = scenarioURLs
        case .studyProduct1:
            filteredURLs = scenarioURLs.filter { $0.lastPathComponent.hasPrefix("HF-1-") }
        case .studyProduct2:
            filteredURLs = scenarioURLs.filter { $0.lastPathComponent.hasPrefix("HF-2-") }
        }

        return filteredURLs.map {
            LoopScenario(
                name: $0                                            // /Scenarios/HF-1-Scenario_1.json
                    .deletingPathExtension()                        // /Scenarios/HF-1-Scenario_1
                    .lastPathComponent                              // HF-1-Scenario_1
                    .replacingOccurrences(of: "HF-1-", with: "")    // Scenario_1
                    .replacingOccurrences(of: "HF-2-", with: "")    // Scenario_1
                    .replacingOccurrences(of: "_", with: " "),      // Scenario 1,
                url: $0
            )
        }
    }
    
    public func loopWillReset() {
        _studyProductSelection = UserDefaults.appGroup?.studyProductSelection
    }
    
    public func loopDidReset() {
        UserDefaults.appGroup?.studyProductSelection = _studyProductSelection
        _studyProductSelection = nil
    }
}
