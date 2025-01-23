//
//  SystemSettingsSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 9.12.2024.
//

import CucumberSwift
import CucumberSwiftExpressions
import LoopUITestingKit

func systemSettingsSteps() {
    let systemSettingsScreen = SystemSettingsScreen(app: systemSettings)
    
    // MARK: Actions
    
    When(/^I (enable|disable) notifications and (enable|disable) critical alerts$/) { matches, _ in
        systemSettings.launch()
        systemSettingsScreen.openAppSettings(appName: appName)
        systemSettingsScreen.tapNotificationsButton()
        systemSettingsScreen.toggleAllowNotifications(enableNotifications: matches.1 == "enable")
        systemSettingsScreen.toggleCriticalAlerts(enableCriticalAlerts: matches.2 == "enable")
    }
}
