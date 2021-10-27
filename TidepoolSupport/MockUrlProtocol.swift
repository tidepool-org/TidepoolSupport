//
//  MockUrlProtocol.swift
//  TidepoolSupport
//
//  Created by Rick Pasetto on 10/26/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import Foundation

class MockURLProtocol: URLProtocol {
    static var lookupResponse: String? = nil // JSON response
    
    enum Error: Swift.Error { case badResponse, badRequest }
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() {
        do {
            let (response, data)  = try requestHandler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch  {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
    
    private func requestHandler(_ request: URLRequest) throws -> (HTTPURLResponse, Data) {
        guard let url = request.url else {
            throw Error.badRequest
        }
        guard let response = HTTPURLResponse.init(url: url, statusCode: 200, httpVersion: "2.0", headerFields: nil),
              let lookupResponse = MockURLProtocol.lookupResponse,
              !lookupResponse.isEmpty,
              let data = lookupResponse.data(using: .utf8) else {
                  throw Error.badResponse
              }
        return (response, data)
    }
}
