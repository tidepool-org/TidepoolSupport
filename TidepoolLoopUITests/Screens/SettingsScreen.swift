//
//  SettingsScreen.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 19.11.2024.
//

import XCTest

public final class SettingsScreen {
    
    // MARK: Elements
    
    private let insulinPump = app.descendants(matching: .any).matching(identifier: "settingsViewInsulinPump").firstMatch
    private let pumpSimulatorButton = app.buttons["Pump Simulator"]
    private let pumpSimulatorDoneButton = app.navigationBars["Pump Simulator"].buttons["Done"]
    private let cgm = app.descendants(matching: .any).matching(identifier: "settingsViewCGM").firstMatch
    private let cgmSimulatorButton = app.buttons["CGM Simulator"]
    private let settingsDoneButton = app.navigationBars["Settings"].buttons["Done"]
    private let alertManagementAlertWarning = app.images["settingsViewAlertManagementAlertWarning"]
    private let alertManagementButton = app.buttons["settingsViewAlertManagement"].firstMatch
    private let alertPermissionsWarningImage =
        app.images["settingsViewAlertManagementAlertPermissionsAlertWarning"]
    private let manageIosPermissionsButton = app.buttons["Manage iOS Permissions"]
    private let alertPermissionsNotificationsEnabled =
        app.staticTexts["settingsViewAlertManagementAlertPermissionsNotificationsEnabled"]
    private let alertPermissionsNotificationsDisabled =
        app.staticTexts["settingsViewAlertManagementAlertPermissionsNotificationsDisabled"]
    private let alertPermissionsCriticalAlertsEnabled =
        app.staticTexts["settingsViewAlertManagementAlertPermissionsCriticalAlertsEnabled"]
    private let alertPermissionsCriticalAlertsDisabled =
        app.staticTexts["settingsViewAlertManagementAlertPermissionsCriticalAlertsDisabled"]
    private let closedLoopToggle =
        app.descendants(matching: .any).matching(identifier: "settingsViewClosedLoopToggle").switches.firstMatch
    private let confirmCloseLoopToggle = app.buttons["Yes, turn OFF"].firstMatch
    private let iOsPermissionsButton =
        app.buttons.containing(NSPredicate(format: "label == 'iOS Permissions'")).firstMatch
    
    // MARK: Actions
    
    func tapInsulinPump() {
        insulinPump.safeTap()
    }
    
    func tapPumpSimulatorDoneButton() {
        pumpSimulatorDoneButton.safeTap()
    }
    
    func tapCGMManager() {
        cgm.safeTap()
    }
    
    func tapSettingsDoneButton() {
        settingsDoneButton.safeTap()
    }
    
    func tapAlertManagementButton() {
        alertManagementButton.safeTap()
    }
    
    func tapiOsPermissionsButton() {
        iOsPermissionsButton.safeTap()
    }
    
    func tapManageIosPermissionsButton() {
        manageIosPermissionsButton.safeTap()
    }
    
    func toggleClosedLoop() {
        closedLoopToggle.safeTap()
        _ = confirmCloseLoopToggle.tapIfExists(timeout: 3)
    }
    
    // MARK: Verifications
    
    var isClosedLoopToggleOn: Bool {
        closedLoopToggle.getValueSafe() == "1"
    }
    
    var alertWarningExists: Bool {
        alertManagementAlertWarning.safeExists
    }
    
    var alertPermissionsWarningImageExists: Bool {
        alertPermissionsWarningImage.safeExists
    }
    
    var alertPermissionsNotificationsDisabledExists: Bool {
        alertPermissionsNotificationsDisabled.safeExists
    }
    
    var alertPermissionsNotificationsEnabledExists: Bool {
        alertPermissionsNotificationsEnabled.safeExists
    }
    
    var alertPermissionsCriticalAlertsDisabledExists: Bool {
        alertPermissionsCriticalAlertsDisabled.safeExists
    }
    
    var alertPermissionsCriticalAlertsEnabledExists: Bool {
        alertPermissionsCriticalAlertsEnabled.safeExists
    }
}
