//
//  SettingsSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 20.11.2024.
//

import XCTest

class SettingsSteps {
    let settingsScreen = SettingsScreen()
    
    // MARK: Actions
    
    func when_i_open_pump_manager() {
        settingsScreen.tapInsulinPump()
    }
    
    func when_i_open_cgm_manager() {
        settingsScreen.tapCGMManager()
    }
    
    func when_i_navigate_to_ios_permissions() {
        settingsScreen.tapiOsPermissionsButton()
    }
    
    func when_i_navigate_to_manage_ios_permissions() {
        settingsScreen.tapManageIosPermissionsButton()
    }
    
    func when_i_close_settings_screen() {
        settingsScreen.tapSettingsDoneButton()
    }
    
    func when_i_open_alert_management() {
        settingsScreen.tapAlertManagementButton()
    }
    
    func when_i_turn_x_closed_loop(turnOn: Bool) {
        if settingsScreen.isClosedLoopToggleOn != turnOn {
            settingsScreen.toggleClosedLoop()
        }
    }
    
    // MARK: Verifications
    
    func then_alert_warning_image_displays() {
        XCTAssert(settingsScreen.alertWarningExists)
    }
    
    func then_permissions_alert_warning_image_displays() {
        XCTAssert(settingsScreen.alertPermissionsWarningImageExists)
    }
    
    func then_ios_permissions_notifications_displays(notificationsEnabled: Bool) {
        if notificationsEnabled {
            XCTAssert(settingsScreen.alertPermissionsNotificationsEnabledExists)
        } else {
            XCTAssert(settingsScreen.alertPermissionsNotificationsDisabledExists)
        }
    }
    
    func then_ios_permissions_critical_alerts_displays(notificationsEnabled: Bool) {
        if notificationsEnabled {
            XCTAssert(settingsScreen.alertPermissionsCriticalAlertsEnabledExists)
        } else {
            XCTAssert(settingsScreen.alertPermissionsCriticalAlertsDisabledExists)
        }
    }
}
