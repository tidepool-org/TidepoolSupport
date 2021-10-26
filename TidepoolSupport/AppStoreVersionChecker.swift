//
//  AppStoreVersionChecker.swift
//  TidepoolSupport
//
//  Created by Rick Pasetto on 10/4/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import LoopKit
import LoopKitUI

class AppStoreVersionChecker {
           
    fileprivate static let encoder = JSONEncoder()
    fileprivate static let decoder = JSONDecoder()

    func checkVersion(bundleIdentifier: String, currentVersion: String, completion: @escaping (Result<VersionUpdate?, Error>) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            self.getAppInfo(bundleIdentifier) { result in
                switch result {
                case .success(let info):
                    if let appStoreVersion = SemanticVersion(info.version),
                       let current = SemanticVersion(currentVersion),
                       appStoreVersion > current
                    {
                        completion(.success(.available))
                    } else {
                        completion(.success(VersionUpdate.none))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    fileprivate enum VersionError: Error {
        case invalidBundleInfo, invalidResponse, noResults
    }
    
    fileprivate struct LookupResult: Codable {
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
    
    private func getAppInfo(_ bundleIdentifier: String, completion: @escaping (Result<AppInfo, Error>) -> Void) {
        
        guard let url = URL(string: "http://itunes.apple.com/us/lookup?bundleId=\(bundleIdentifier)") else {
            completion(.failure(VersionError.invalidBundleInfo))
            return
        }
        let task = session.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error {
                    throw error
                }
                guard let data = data else {
                    throw VersionError.invalidResponse
                }
                let result = try Self.decoder.decode(LookupResult.self, from: data)
                guard let info = result.results.first else {
                    throw VersionError.noResults
                }
                completion(.success(info))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
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
    init?(from json: String) {
        guard let data = json.data(using: .utf8),
              let result = try? AppStoreVersionChecker.decoder.decode(AppStoreVersionChecker.LookupResult.self, from: data)
              else {
            return nil
        }
        self = result
    }

    func toJSON() -> String? {
        guard let data = try? AppStoreVersionChecker.encoder.encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
