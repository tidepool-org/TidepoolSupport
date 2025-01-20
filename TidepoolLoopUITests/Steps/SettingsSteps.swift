//
//  SettingsSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 20.11.2024.
//

import CucumberSwift
import LoopUITestingKit
import XCTest

func settingsSteps()  {
    let settingsScreen = SettingsScreen(app: app)
    let homeScreen = HomeScreen(app: app)
    
    // MARK: Actions
    
    When("I open pump manager from settings") { _, _ in
        app.swipeUp()
        settingsScreen.tapInsulinPump()
    }
    
    When("I open cgm manager from settings") { _, _ in
        settingsScreen.tapCGMManager()
    }
    
    When("I navigate to iOS permissions") { _, _ in
        settingsScreen.tapiOsPermissionsButton()
    }
    
    When("I navigate to manage iOS permissions")  { _, _ in
        settingsScreen.tapManageIosPermissionsButton()
    }
    
    When("I close settings screen") { _, _ in
        settingsScreen.tapSettingsDoneButton()
    }
    
    When("I open alert management") { _, _ in
        settingsScreen.tapAlertManagementButton()
    }
    
    When(/^I turn (on|off) closed loop$/) { matches, _ in
        if !settingsScreen.closedLoopToggleEnabled {
            app.terminate()
            app.launch()
            homeScreen.tapSettingsButton()
        }
        if settingsScreen.isClosedLoopToggleOn != (matches.1 == "on")  {
            settingsScreen.toggleClosedLoop()
        }
    }
    
    // MARK: Verifications
    
    Then("alert warning image displays") { _, _ in
        XCTAssert(settingsScreen.alertWarningExists)
    }
    
    Then("permissions alert warning image displays") { _, _ in
        XCTAssert(settingsScreen.alertPermissionsWarningImageExists)
    }
    
    Then(/^iOS permissions notifications (enabled|disabled) displays$/) { matches, _ in
        if matches.1 == "enabled"  {
            XCTAssert(settingsScreen.alertPermissionsNotificationsEnabledExists)
        } else  {
            XCTAssert(settingsScreen.alertPermissionsNotificationsDisabledExists)
        }
    }
    
    Then(/^iOS permissions critical alerts (enabled|disabled) displays$/) { matches, _ in
        if matches.1 == "enabled"  {
            XCTAssert(settingsScreen.alertPermissionsCriticalAlertsEnabledExists)
        } else  {
            XCTAssert(settingsScreen.alertPermissionsCriticalAlertsDisabledExists)
        }
    }
}
