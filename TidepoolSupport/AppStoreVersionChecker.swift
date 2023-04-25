//
//  AppStoreVersionChecker.swift
//  TidepoolSupport
//
//  Created by Rick Pasetto on 10/4/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import LoopKit
import LoopKitUI
import os.log

class AppStoreVersionChecker {

    private let log = OSLog(category: "AppStoreVersionChecker")

    func checkVersion(bundleIdentifier: String, currentVersion: String) async -> VersionUpdate? {
        do {
            let info = try await getAppInfo(bundleIdentifier)
            if let appStoreVersion = SemanticVersion(info.version),
               let current = SemanticVersion(currentVersion),
               appStoreVersion > current
            {
                return .available
            } else {
                return .noUpdateNeeded
            }
        } catch {
            log.error("checkVersion failed: %@", error.localizedDescription)
            return nil
        }
    }
    
    fileprivate enum VersionError: Error {
        case invalidBundleInfo, invalidResponse, noResults
    }
    
    fileprivate struct LookupResult: Codable {
        private static let encoder = JSONEncoder()
        private static let decoder = JSONDecoder()

        let results: [AppInfo]
    }
    
    fileprivate struct AppInfo: Codable {
        let version: String
        let trackViewUrl: String
    }
    
    private var session: URLSession {
        if let mockAppStoreVersionString = UserDefaults.appGroup?.mockAppStoreVersionResponse,
           let mockAppStoreVersion = SemanticVersion(mockAppStoreVersionString),
           let mockAppStoreVersionResult = LookupResult(results: [AppInfo(version: mockAppStoreVersion.description, trackViewUrl: "")]).toJSON()
        {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.protocolClasses = [MockURLProtocol.self]
            MockURLProtocol.lookupResponse = mockAppStoreVersionResult
            return URLSession(configuration: configuration)
        } else {
            return URLSession.shared
        }
    }
    
    private func getAppInfo(_ bundleIdentifier: String) async throws -> AppInfo {
        
        guard let url = URL(string: "http://itunes.apple.com/us/lookup?bundleId=\(bundleIdentifier)") else {
            throw VersionError.invalidBundleInfo
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let result = try LookupResult(from: data)
        guard let info = result.results.first else {
            throw VersionError.noResults
        }
        return info
    }
}

extension AppStoreVersionChecker.VersionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidBundleInfo: return "Invalid Bundle Info (bad build?)"
        case .invalidResponse: return "Unexpected response payload"
        case .noResults: return "No Results"
        }
    }
}

extension AppStoreVersionChecker.LookupResult {
    init(from data: Data) throws {
        self = try Self.decoder.decode(Self.self, from: data)
    }

    func toJSON() -> String? {
        guard let data = try? Self.encoder.encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
