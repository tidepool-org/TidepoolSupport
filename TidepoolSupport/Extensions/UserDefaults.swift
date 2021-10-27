//
//  UserDefaults.swift
//  TidepoolSupport
//
//  Created by Rick Pasetto on 10/26/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

extension UserDefaults {
    
    public static let appGroup = UserDefaults(suiteName: Bundle.main.appGroupSuiteName)

    private enum Key: String {
        case mockAppStoreResponse = "org.tidepool.plugins.TidepoolSupport.MockAppStoreResponse"
    }
    
    var mockAppStoreVersionResponse: String? {
        get {
            string(forKey: Key.mockAppStoreResponse.rawValue)
        }
        set {
            set(newValue, forKey: Key.mockAppStoreResponse.rawValue)
        }
    }
}
