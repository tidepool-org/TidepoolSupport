//
//  OnboardingSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 19.11.2024.
//

import LoopUITestingKit
import CucumberSwift

func onboardingSteps() {
    let onboardingScreen = OnboardingScreen(app: app)
    
    // MARK: Actions
    
    When("I skip all of onboarding") { _, _ in
        skipOnboarding()
        onboardingScreen.allowNotifications()
        onboardingScreen.allowCriticalAlerts()
        onboardingScreen.allowHealthKitAuthorization()
    }

    When("I skip onboarding") { _, _ in
        skipOnboarding()
    }
    
    When("I skip onboarding to Therapy Settings") { _, _ in
        skipWelcomScreen()
        onboardingScreen.tapForDurationDayInLife()
        onboardingScreen.tapConfirmSkipOnboarding()
    }
    
    When("I navigate to Therapy Settings from onboarding") { _, _ in
        onboardingScreen.tapYourSettingsButton()
        onboardingScreen.tapForDurationYourSettingsTitle()
        onboardingScreen.tapConfirmSkipOnboarding()
        app.swipeUp()
        onboardingScreen.tapContinueYourSettingsButton()
    }
    
    // MARK: Helpers
    
    func skipOnboarding() {
        for _ in 1...3 {
            onboardingScreen.tapForDurationWelcomTitle()
            if onboardingScreen.skipOnboardingAlertExists {
                onboardingScreen.tapConfirmSkipOnboarding()
                break
            }
        }
    }
    
    func skipWelcomScreen() {
        for _ in 1...6 {
            onboardingScreen.tapContinueButton()
        }
        onboardingScreen.tapFinishButton()
    }
}
