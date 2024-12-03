//
//  Notifications.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 26.11.2024.
//

import XCTest

class Notifications {
    
    // MARK: Elements
    
    private let notification = springBoard
        .descendants(matching: .any)
        .matching(identifier: "NotificationShortLookView")
        .element
    
    // MARK: Verifications
    
    var getNotificationLabel: String {
        notification.getLableSafe()
    }
}
