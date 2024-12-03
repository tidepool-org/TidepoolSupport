//
//  CommonSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 18.11.2024.
//

class CommonSteps {
    let onboardingSteps = OnboardingSteps()
    let systemSettingsScreen = SystemSettingsScreen()
    
    // MARK: Preconditions
    
    func given_app_is_launched() {
        app.launch()
    }
    
    func given_app_is_launched_and_intialy_setup() {
        app.launch()
        onboardingSteps.when_i_skip_all_of_onboarding()
    }
    
    // MARK: Actions
    
    func when_i_switch_to_tidepool_loop_app() {
        app.activate()
    }
    
    func when_i_return_to_tidepool_loop_app() {
        systemSettingsScreen.tapReturnToTidepoolButton()
    }
}
