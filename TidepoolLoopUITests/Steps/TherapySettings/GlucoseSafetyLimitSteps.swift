//
//  GlucoseSafetyLimitSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 15.01.2025.
//

import CucumberSwift
import LoopUITestingKit
import XCTest

func glucoseSafetyLimitSteps() {
    let therapySettingsScreen = TherapySettingsScreen(app: app)
    let navigationBar = NavigationBar(app: app)
    let homeScreen = HomeScreen(app: app)
    let settingsScreen = SettingsScreen(app: app)
    let passcodeScreen = PasscodeScreen(app: app)
    
    // MARK: Actions
    
    When(/^I set glucose safety limit value to (\d+) mg\/dL$/) { matches, _ in
        if therapySettingsScreen.glucoseSafetyLimitValueTextExists {
            therapySettingsScreen.tapGlucoseSafetyLimitValueText()
        }
        if !therapySettingsScreen.pickerWheelExists { therapySettingsScreen.tapSetGlucoseValueText() }
        therapySettingsScreen.setPickerWheelValue(value: String(matches.1))
    }
    
    When(/^I update Glucose Safety limit value to (\d+) mg\/dL$/) { matches, _ in
        if homeScreen.carbsTabButtonisHittable {
            homeScreen.tapSettingsButton()
            settingsScreen.tapTherapySettingsButton()
            therapySettingsScreen.tapGlucoseSafetyLimitText()
        }
        
        therapySettingsScreen.tapSetGlucoseValueText()
        therapySettingsScreen.setPickerWheelValue(value: String(matches.1))
        if therapySettingsScreen.confirmSaveButtonIsEnabled { therapySettingsScreen.tapConfirmSaveButton() }
        else { navigationBar.tapTherapySettingsBackButton() }
    }
    
    // MARK: Verifications
    
    Then(/^Glucose Safety Limit is set to (\d+) mg\/dL(| in the Onboarding overview)$/) { matches, _ in
        XCTAssertEqual(
            String(matches.1),
            String(therapySettingsScreen.getGlucoseSafetyLimitValue.split(separator: ", ").first!)
        )
    }
}
