//
//  SystemSettingsScreen.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 19.11.2024.
//

import XCTest

public final class SystemSettingsScreen {
        
    // MARK: Elements
    
    private let appNameButton = systemSettings.buttons["Tidepool Loop"]
    private let notificationsButton =
        systemSettings.descendants(matching: .any).element(matching: .button, identifier: "NOTIFICATIONS")
    private let notificationsToggle =
        systemSettings.switches["Allow Notifications"]
    private let criticalAlertsToggle =
        systemSettings.switches["Critical Alerts"]
    private let returnToTidepoolButton = springBoard.buttons["Return to Tidepool Loop"]
    
    // MARK: Actions
    
    func openAppSettings(appName: String) {
        while !systemSettings.buttons["Apps"].exists {
            systemSettings.swipeUp()
        }
        systemSettings.buttons["Apps"].tap()
        while !appNameButton.exists {
            systemSettings.swipeUp()
        }
        systemSettings.buttons[appName].tap()
    }
    
    func tapNotificationsButton() {
        notificationsButton.safeTap()
    }
    
    func tapReturnToTidepoolButton() {
        returnToTidepoolButton.safeTap()
    }
    
    func toggleAllowNotifications(enableNotifications: Bool = true) {
        let shouldBeEnabled = enableNotifications ? "1" : "0"
        
        if notificationsToggle.getValueSafe() != shouldBeEnabled {
            notificationsToggle.tap()
        }
    }
    
    func toggleCriticalAlerts(enableCriticalAlerts: Bool = true) {
        let shouldBeEnabled = enableCriticalAlerts ? "1" : "0"
        
        if criticalAlertsToggle.getValueSafe() != shouldBeEnabled {
            criticalAlertsToggle.tap()
        }
    }
}
