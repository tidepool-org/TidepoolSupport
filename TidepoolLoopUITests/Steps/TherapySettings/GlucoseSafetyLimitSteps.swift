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
    
    //MARK: Actions
    
    
    When(/^I set glucose safety limit value to (\d+) mg\/dL$/) { matches, _ in
        if !therapySettingsScreen.pickerWheelExists { therapySettingsScreen.tapSetGlucoseValueText() }
        therapySettingsScreen.setPickerWheelValue(value: String(matches.1))
    }
    
    //MARK: Verifications
    
    Then(/^Glucose Safety Limit is set to (\d+) mg\/dL(| in the Onboarding overview)$/) { matches, _ in
        XCTAssertEqual(
            String(matches.1),
            String(therapySettingsScreen.getGlucoseSafetyLimitValue.split(separator: ", ").first!)
        )
    }
}
