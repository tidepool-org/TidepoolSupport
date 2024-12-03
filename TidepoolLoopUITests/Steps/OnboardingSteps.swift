//
//  OnboardingSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 19.11.2024.
//

class OnboardingSteps {
    let onboardingScreen = OnboardingScreen()
    
    // MARK: Actions
    
    func when_i_skip_all_of_onboarding() {
        when_i_skip_onboarding()
        onboardingScreen.allowNotifications()
        onboardingScreen.allowCriticalAlerts()
        onboardingScreen.allowHealthKitAuthorization()
    }

    func when_i_skip_onboarding() {
        for _ in 1...3 {
            onboardingScreen.tapForDurationWelcomTitle()
            if onboardingScreen.skipOnboardingAlertExists {
                onboardingScreen.tapConfirmSkipOnboarding()
                break
            }
        }
    }
}
