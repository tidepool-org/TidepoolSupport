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
    let carbsEntryScreen = CarbsEntryScreen(app: app)
    let passcodeScreen = PasscodeScreen(app: app)
    
    // MARK: Actions
    
    When("I close bolus screen") { _, _ in
        bolusScreen.tapCancelBolusButton()
    }
    
    When("I set bolus screen values") { _, step in // Applies to Closed/Open Manual/Meal bolus screens.
        
        let bolusScreenMap = step.dataTable!.rows.map {
            row -> (key: String, value: String) in (key: row[0], value: row[1])
        }
        for textField in bolusScreenMap {
            app.swipeUp()
            switch textField.key {
            case "CurrentGlucose":
                bolusScreen.tapCurrentGlucoseTextField()
                bolusScreen.clearCurrentGlucoseTextFieldValue()
                bolusScreen.setCurrentGlucoseTextFieldValue(textField.value)
            case "FingerstickGlucose":
                bolusScreen.tapFingerstickGlucoseTextField()
                bolusScreen.clearFingerstickGlucoseTextFieldValue()
                bolusScreen.setFingerstickGlucoseTextFieldValue(textField.value)
            case "Carbohydrates":
                bolusScreen.tapCarbohydratesTextField()
                bolusScreen.clearCarbohydratesTextFieldValue()
                bolusScreen.setCarbohydratesTextFieldValue(textField.value)
            case "Bolus":
                bolusScreen.tapBolusTextField()
                bolusScreen.clearBolusTextFieldValue()
                bolusScreen.setBolusTextFieldValue(textField.value)
            default:
                XCTFail("Unsupported field \(textField.key)")
            }
            bolusScreen.tapKeyboardDoneButton()
        }
    }
    
    When(/^I tap (Save and Deliver|Save without Bolusing|Enter Bolus) button$/) { _, _ in
        bolusScreen.tapBolusActionButton()
    }
    
    When("I cancel bolus authentication") { _, _ in
        passcodeScreen.cancelPasscode()
    }

    When("I deliver and authenticate bolus") { _, _ in
        bolusScreen.tapBolusActionButton()
        passcodeScreen.setPasscode()
    }
    
    When(/^I tap "Enter Fingerstick Glucose"$/) { _, _ in
        bolusScreen.tapEnterFingerstickGlucoseButton()
    }
    
    // MARK: Verifications
    
    Then("simple bolus calculator displays") { _, _ in
        XCTAssert(bolusScreen.simpleBolusCalculatorTitleExists)
    }
    
    Then(/^(meal |)bolus screen displays$/) { matches, _ in
        if(matches.1.isEmpty) { XCTAssert(bolusScreen.bolusTitleExists) }
        else{ XCTAssert(carbsEntryScreen.mealBolusScreenExists) }
    }
    
    Then(/^warning title (does not |)display[s]? "?(.*?)"?$/) { matches, _ in
        let expectedValue = String(matches.2)
        let warningIsExpected = matches.1.isEmpty
        let errorMsg = warningIsExpected ? "does not display" : "displays"
        
        XCTAssertTrue(
            warningIsExpected == therapySettingsScreen.guardrailWarningTextExists,
            "Warning title incorrectly \(errorMsg)"
        )
        if warningIsExpected { XCTAssertEqual(expectedValue, therapySettingsScreen.getGuardrailWarningValue) }
    }
    
    Then(/^(bolus|current glucose|carbohydrates|recommended bolus|fingerstick glucose) field (displays|is not|is greater than|is less than) value "?(.*?)"?$/) { matches, _ in
        app.swipeUp()
        let expectedValue = String(matches.3)
        let actualValue = switch matches.1 {
        case "current glucose": bolusScreen.getCurrentGlucoseTextFieldValue
        case "fingerstick glucose": bolusScreen.getFingerstickGlucoseTextFieldValue
        case "carbohydrates": bolusScreen.getCarbohydratesTextFieldValue
        case "recommended bolus": bolusScreen.getRecommendedBolusStaticTextValue
        case "bolus": bolusScreen.getBolusTextFieldValue
        default: ""
        }
        if actualValue.isEmpty {
            XCTFail("The field \(matches.1) does not exist or is not currently supported.")
            return
        }
        switch matches.2 {
        case "displays":
            XCTAssertEqual(
                actualValue,
                expectedValue,
                "Equal comparison of expected `\(matches.1)` value `\(expectedValue)` is not equal to actual value `\(actualValue)`.")
        case "is not":
            XCTAssertNotEqual(
                actualValue,
                expectedValue,
                "Not Equal Comparison of expected `\(matches.1)` value `\(expectedValue)` is equal to actual value `\(actualValue)`.")
        case "is greater than":
            XCTAssertGreaterThan(
                actualValue,
                expectedValue,
                "Greater than comparison of expected `\(matches.1)` value `\(expectedValue)` is equal to or less than actual value `\(actualValue)`.")
        case "is less than":
            XCTAssertLessThan(
                actualValue,
                expectedValue,
                "Less than comparison of expected `\(matches.1)` value `\(expectedValue)` is equal to or greater than actual value `\(actualValue)`.")
        default:
            XCTFail("Opperator option: \(matches.2) is not supported or valid.")
        }
    }

	Then(/^Active Carbs value on Meal Bolus screen displays "(.*)"$/) { matches, _ in
        XCTAssertEqual(String(matches.1), bolusScreen.getActiveCarbsText.components(separatedBy: ", ")[1])
	}
}
