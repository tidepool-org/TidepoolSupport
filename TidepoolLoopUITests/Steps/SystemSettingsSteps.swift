//
//  SystemSettingsSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 21.11.2024.
//

class SystemSettingsSteps {
    let systemSettingsScreen = SystemSettingsScreen()
    
    // MARK: Actions
    
    func when_i_setup_app_notifications(allowNotifications: Bool, allowCriticalNotifications: Bool) {
        systemSettings.launch()
        systemSettingsScreen.openAppSettings(appName: "Tidepool Loop")
        systemSettingsScreen.tapNotificationsButton()
        systemSettingsScreen.toggleAllowNotifications(enableNotifications: allowNotifications)
        systemSettingsScreen.toggleCriticalAlerts(enableCriticalAlerts: allowCriticalNotifications)
    }
    
    func when_i_switch_to_system_settings() {
        
    }
}
