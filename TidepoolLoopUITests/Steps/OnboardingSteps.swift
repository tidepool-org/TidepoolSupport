//
//  OnboardingSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 19.11.2024.
//

import CucumberSwift

func onboardingSteps() {
    let onboardingScreen = OnboardingScreen()
    
    // MARK: Actions
    
    When("I skip all of onboarding") { _, _ in
        onboardingScreen.skipOnboarding()
        onboardingScreen.allowNotifications()
        onboardingScreen.allowCriticalAlerts()
        onboardingScreen.allowHealthKitAuthorization()
    }

    When("I skip onboarding") { _, _ in
        onboardingScreen.skipOnboarding()
    }
}
