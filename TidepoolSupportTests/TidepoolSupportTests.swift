//
//  TidepoolSupportTests.swift
//  TidepoolSupportTests
//
//  Created by Rick Pasetto on 10/11/21.
//

import XCTest
import LoopKit
@testable import TidepoolKit
@testable import TidepoolSupport

class TidepoolSupportTests: XCTestCase {
    static let timeout = TimeInterval(seconds: 5)
    static var randomString: String { UUID().uuidString }
    static let info = TInfo(versions: TInfo.Versions(loop: TInfo.Versions.Loop(minimumSupported: "1.2.3", criticalUpdateNeeded: ["1.0.0", "1.1.0"])))
    
    let authenticationToken = randomString
    let refreshAuthenticationToken = randomString
    let userId = randomString
    var support: TidepoolSupport!
    enum TestError: Error {
       case test
    }

    override func setUp() async throws {
        try await super.setUp()
        
        URLProtocolMock.handlers = []

        let environment = TEnvironment(host: "test.org", port: 443)
        support = TidepoolSupport(environment)

        let urlSessionConfiguration = await support.tapi.urlSessionConfiguration
        urlSessionConfiguration.protocolClasses = [URLProtocolMock.self]
        await support.tapi.setURLSessionConfiguration(urlSessionConfiguration)
    }

    override func tearDown() {
        XCTAssertTrue(URLProtocolMock.handlers.isEmpty)
    }

    func setupToReturnInfo() {
        URLProtocolMock.handlers = [URLProtocolMock.Handler(validator: URLProtocolMock.Validator(url: "https://test.org/info", method: "GET"),
                                                            success: URLProtocolMock.Success(statusCode: 200, body: Self.info))]
    }
    
    func setupToReturnErrorOnInfo() {
        URLProtocolMock.handlers = [URLProtocolMock.Handler(validator: URLProtocolMock.Validator(url: "https://test.org/info", method: "GET"),
                                                            error: TestError.test)]
    }

    func testCheckVersion() async throws {
        setupToReturnInfo()

        let result = await support.checkVersion(bundleIdentifier: "org.tidepool.Loop", currentVersion: "1.2.0")
        XCTAssertEqual(VersionUpdate.recommended, result)
    }
    
    func testCheckVersionReturnsNilForOtherBundleIdentifiers() async throws {
        setupToReturnInfo()
        let result = await support.checkVersion(bundleIdentifier: "foo.bar", currentVersion: "1.2.0")
        XCTAssertNil(result)
    }
    
    func testCheckVersionError() async throws {
        setupToReturnErrorOnInfo()
        let result = await support.checkVersion(bundleIdentifier: "org.tidepool.Loop", currentVersion: "1.2.0")
        XCTAssertNil(result)
    }
    
    func testCheckVersionReturnsLastResultOnError() async throws {
        setupToReturnInfo()
        let result = await support.checkVersion(bundleIdentifier: "org.tidepool.Loop", currentVersion: "1.2.0")
        XCTAssertEqual(VersionUpdate.recommended, result)
        
        setupToReturnErrorOnInfo()
        let result2 = await support.checkVersion(bundleIdentifier: "org.tidepool.Loop", currentVersion: "1.2.0")
        XCTAssertEqual(VersionUpdate.recommended, result2)
    }
}

extension Result {
    var value: Success? {
        switch self {
        case .failure: return nil
        case .success(let val): return val
        }
    }
    var error: Failure? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}
