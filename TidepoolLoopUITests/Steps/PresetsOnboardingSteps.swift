//
//  PresetsOnboardingSteps.swift
//  TidepoolSupport
//
//  Created by Scott Foster on 10/28/25.
//

import CucumberSwift
import CucumberSwiftExpressions
import LoopUITestingKit
import XCTest


func presetssOnboardingSteps() {
    
    let presetsOnboardingScreen = PresetsOnboardingScreen(app: app)
    let homeScreen = HomeScreen(app: app)
    let therapySettingsScreen = TherapySettingsScreen(app: app)
    
    
    When("I skip Preset Onboarding") { _, _ in
        if homeScreen.carbsTabButtonisHittable {
            homeScreen.tapPresetsTabButton()
        }
        presetsOnboardingScreen.tapForDurationPresetsTrainingTitleText()
        presetsOnboardingScreen.tapTrainingCompleteSkipOption()
        presetsOnboardingScreen.tapPresetsTrainingCard()
        therapySettingsScreen.tapCloseButton()
        XCTAssert(!presetsOnboardingScreen.presetsTrainingCardExists )
    }
    
    Then("Presets Training screen displays") { _, _ in
        XCTAssert(presetsOnboardingScreen.presetsTrainingTitleTextExists)
    }
    
    
}
