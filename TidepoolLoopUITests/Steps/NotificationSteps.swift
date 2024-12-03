//
//  NotificationSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 26.11.2024.
//

import XCTest
import CucumberSwift

func notificationSteps() {
    let notifications = Notifications()

    Then(/^notification displays$/) { _, step in
        let tableHeader = step.dataTable!.rows[0]
        let tableData = step.dataTable!.rows[1]
        let notificationLabel = notifications.getNotificationLabel
        let titleIndex = tableHeader.firstIndex(where: {$0.contains("Title")})
        let bodyIndex = tableHeader.firstIndex(where: {$0.contains("Body")})
        
        XCTAssert(notificationLabel.contains(tableData[0]))
        titleIndex != nil ? XCTAssert(notificationLabel.contains(tableData[titleIndex!])) :
            print("Title is a mandatory column.")
        bodyIndex != nil ? XCTAssert(notificationLabel.contains(tableData[bodyIndex!])) : ()
    }
}
