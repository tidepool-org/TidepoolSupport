//
//  NotificationSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 26.11.2024.
//

import XCTest

class NotificationSteps {
    let notifications = Notifications()
    
    func then_notification_title_body_displays(title: String, body: String?) {
        let notificationLabel = notifications.getNotificationLabel
        XCTAssert(notificationLabel.contains(title))
        if body != nil { XCTAssert(notificationLabel.contains(body!)) }
    }
}
