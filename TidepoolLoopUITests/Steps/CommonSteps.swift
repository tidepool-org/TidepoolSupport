//
//  CommonSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 18.11.2024.
//
import CucumberSwift

func commonSteps() {
    let systemSettingsScreen = SystemSettingsScreen()
    let onboardingScreen = OnboardingScreen()
    
    // MARK: Preconditions
    
    Given("app is launched") { _, _ in
        app.launch()
    }
    
    Given("app is launched and intialy setup") { _, _ in
        app.launch()
        onboardingScreen.skipOnboarding()
        onboardingScreen.allowNotifications()
        onboardingScreen.allowCriticalAlerts()
        onboardingScreen.allowHealthKitAuthorization()
    }
    
    // MARK: Actions
    
    When("I switch to tidepool loop app") { _, _ in
        app.activate()
    }
    
    When("I return to tidepool loop app") { _, _ in
        systemSettingsScreen.tapReturnToTidepoolButton()
    }
}
