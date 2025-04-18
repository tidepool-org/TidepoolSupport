//
//  CommonSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 18.11.2024.
//

import CucumberSwift
import LoopUITestingKit

func commonSteps() {
    let systemSettingsScreen = SystemSettingsScreen(app: app)
    let onboardingScreen = OnboardingScreen(app: app)
    
    // MARK: Preconditions
    
    Given("app is launched") { _, _ in
        app.launch()
    }
    
    Given("app is launched and intialy setup") { _, _ in
        app.launch()
        for _ in 1...3 {
            onboardingScreen.tapForDurationWelcomTitle()
            if onboardingScreen.skipOnboardingAlertExists {
                onboardingScreen.tapConfirmSkipOnboarding()
                break
            }
        }
        onboardingScreen.allowNotifications()
        onboardingScreen.allowCriticalAlerts()
        onboardingScreen.dontAllowHelthKitAuthorization()
    }
    
    // MARK: Actions
    
    When("I switch to tidepool loop app") { _, _ in
        app.activate()
    }
    
    When("I return to tidepool loop app") { _, _ in
        systemSettingsScreen.tapReturnToTidepoolButton(appName: appName)
    }
}
