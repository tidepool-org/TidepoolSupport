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
        case productSelection = "org.tidepool.plugins.TidepoolSupport.ProductSelection"
        case allowDebugFeatures = "com.loopkit.Loop.allowDebugFeatures"
    }
    
    var mockAppStoreVersionResponse: String? {
        get {
            string(forKey: Key.mockAppStoreResponse.rawValue)
        }
        set {
            set(newValue, forKey: Key.mockAppStoreResponse.rawValue)
        }
    }
    
    public var productSelection: String? {
        get {
            string(forKey: Key.productSelection.rawValue)
        }
        set {
            set(newValue, forKey: Key.productSelection.rawValue)
        }
    }
    
    var allowDebugFeatures: Bool {
        get {
            bool(forKey: Key.allowDebugFeatures.rawValue)
        }
        set {
            set(newValue, forKey: Key.allowDebugFeatures.rawValue)
        }
    }
}
