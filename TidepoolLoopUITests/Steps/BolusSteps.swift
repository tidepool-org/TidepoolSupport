//
//  BolusSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 23.11.2024.
//

import CucumberSwift
import CucumberSwiftExpressions
import LoopUITestingKit
import XCTest

func bolusSteps() {
    let bolusScreen = BolusScreen(app: app)
    let therapySettingsScreen = TherapySettingsScreen(app: app)
    
    // MARK: Actions
    
    When("I close bolus screen") { _, _ in
        bolusScreen.tapCancelBolusButton()
    }
    
    When("I set bolus screen values") { _, step in // Applies to Closed/Open Manual/Meal bolus screens. 
        let bolusScreenMap = step.dataTable!.rows.map {
            row -> (key: String, value: String) in (key: row[0], value: row[1])
        }
        for simpleTextField in bolusScreenMap {
            switch simpleTextField.key{
            case "Bolus":
                bolusScreen.tapBolusEntryTextField()
                bolusScreen.clearBolusEntryTextField()
                bolusScreen.setBolusEntryTextField(value: simpleTextField.value)
                bolusScreen.tapKeyboardDoneButton()
            case "CurrentGlucose":
                bolusScreen.tapCurrentGlucoseEntryTextField()
                bolusScreen.clearCurrentGlucoseEntryTextField()
                bolusScreen.setCurrentGlucoseEntryTextField(value: simpleTextField.value)
                bolusScreen.tapKeyboardDoneButton()
            default:
                XCTFail("Unsupported field \(simpleTextField.key)")
            }
        }
    }
    
    When("I deliver and authenticate bolus") { _, _ in
        bolusScreen.tapBolusActionButton()
        bolusScreen.setPasscode()
    }
    
    
    // MARK: Verifications
    
    Then("simple bolus calculator displays") { _, _ in
        XCTAssert(bolusScreen.simpleBolusCalculatorTitleExists)
    }
    
    Then("bolus screen displays") { _, _ in
        XCTAssert(bolusScreen.bolusTitleExists)
    }
    
    Then(/^warning title displays "?(.*?)"?$/) { matches, _ in
        let expectedValue = String(matches.1)
        let actualValue = therapySettingsScreen.getGuardrailWarningValue
        XCTAssertEqual(expectedValue,actualValue, "Comparison of expected warning type `\(matches.1)` does not match the actual warning type `\(actualValue)`.")
    }
    
    Then(/^(bolus|current glucose) field displays value "?(.*?)"?$/) { matches, _ in
        let expectedValue = String(matches.2)
        let actualValue = switch matches.1{
        case "bolus": bolusScreen.getBolusFieldValue()
        case "current glucose": bolusScreen.getCurrentGlucoseFieldValue()
        default: ""
        }
        if actualValue.isEmpty {XCTFail("Unsupported Field: \(matches.1)")}
        XCTAssertEqual(
            expectedValue,
            actualValue,
            "Comparison of expected `\(matches.1)` value `\(expectedValue)` does not match actual value `\(actualValue)`."
        )
    }
}
