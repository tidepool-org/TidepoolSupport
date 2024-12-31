//
//  TherapySettingsSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 30.12.2024.
//

import LoopUITestingKit
import CucumberSwift
import XCTest

func therapySettingsSteps() {
    let therapySettingsScreen = TherapySettingsScreen(app: app)
    let onboardingScreen = OnboardingScreen(app: app)
    let homeScreen = HomeScreen(app: app)
    let cgmScreens = CGMScreens(app: app)
    let pumpScreens = PumpScreens(app: app)
    let settingsScreen = SettingsScreen(app: app)
    
    //MARK: Actions
    
    When("I navigate to Glucose Safety Limit edit screen") { _, _ in
        onboardingScreen.tapYourSettingsButton()
        onboardingScreen.tapForDurationYourSettingsTitle()
        onboardingScreen.tapConfirmSkipOnboarding()
        onboardingScreen.tapContinueYourSettingsButton()
        onboardingScreen.tapContinueButton()
        onboardingScreen.tapContinueButton()
    }
    
    When(/^I set glucose safety limit value to (\d+) mg\/dL$/) { matches, _ in
        if !therapySettingsScreen.pickerWheelExists { therapySettingsScreen.tapSetGlucoseValueText() }
        therapySettingsScreen.setPickerWheelValue(value: String(matches.1))
    }
    
    When("I tap Confirm Setting") { _, _ in
        therapySettingsScreen.tapConfirmSaveButton()
    }
    
    When("I tap Go Back") { _, _ in
        therapySettingsScreen.tapGoBackAlertButton()
    }
    
    When("I confirm glucose safety limit in alert window") { _, _ in
        therapySettingsScreen.tapContinueAlertButton()
    }
    
    When("I navigate back") { _, _ in
        onboardingScreen.tapBackButton()
    }
    
    When("I navigate to the Therapy Settings confirmation screen") { _, _ in
        var maxAttempts = 9
        
        while maxAttempts > 0 {
            onboardingScreen.tapContinueButton()
            therapySettingsScreen.tapConfirmSaveButton()
            if therapySettingsScreen.therapySettingsTitleTextExists { break }
            maxAttempts -= 1
        }
    }
    
    When("I save settings and finish the onboarding") { _, _ in
        therapySettingsScreen.tapSaveSettingsButton()
        onboardingScreen.tapContinueYourSettingsButton()
        onboardingScreen.tapForDurationGettingToKnowTitle()
        onboardingScreen.tapConfirmSkipOnboarding()
        onboardingScreen.allowNotifications()
        onboardingScreen.allowCriticalAlerts()
        onboardingScreen.allowHealthKitAuthorization()
    }
    
    When("I pair CGM simulator") { _, _ in
        homeScreen.tapHudGlucosePill()
        cgmScreens.tapActionSheetCgmSimulatorButton()
    }
    
    When("I pair Pump simulator") { _, _ in
        homeScreen.tapPumpPill()
        pumpScreens.tapActionSheetPumpSimulatorButton()
    }
    
    When("I tap Therapy Settings") { _, _ in
        settingsScreen.tapTherapySettingsButton()
    }
    
    //MARK: Verifications
    
    Then(/^Glucose Safety Limit is set to (.*) mg\/dL$/) { matches, _ in
        XCTAssertEqual(
            String(matches.1),
            String(therapySettingsScreen.getGlucoseSafetyLimitValue.split(separator: ", ").first!)
        )
    }
    
    Then(/^(.*) education screen displays$/) { matches, _ in
        XCTAssertEqual(String(matches.1), therapySettingsScreen.getTherapySettingsEducationTitleText)
    }
    
    Then("alert 'Save Glucose Safety Limit?' appears") { _, _ in
        XCTAssertTrue(
            therapySettingsScreen.glucoseSafetyLimitAlertExists,
            "Alert message 'Save Glucose Safety Limit?' does not appear."
        )
    }
    
    Then(/^(Low|High) Glucose Safety Limit message appears with (red|orange) warning indicators$/) { matches, _ in
        XCTAssertEqual("\(matches.1) Glucose Safety Limit", therapySettingsScreen.getGuardrailWarningValue)
        
        if matches.2 == "red" {
            XCTAssertTrue(therapySettingsScreen.nextToTextWarningTriangleRedImageExists)
            XCTAssertTrue(therapySettingsScreen.guardRailRedWarningTriangleImageExists)
        } else {
            XCTAssertTrue(therapySettingsScreen.nextToTextWarningTriangleOrangeImageExists)
            XCTAssertTrue(therapySettingsScreen.guardRailOrangeWarningTriangleImageExists)
        }
    }
    
    Then(/^Therapy Settings screen displays$/) { _, step in
        let errorMsg = "Table header 'Section' and 'Units' are expected."
        let tableHeader = step.dataTable!.rows[0]
        guard let sectionIndex = tableHeader.firstIndex(where: {$0.contains("Section")}) else { return XCTFail(errorMsg) }
        guard let unitsIndex = tableHeader.firstIndex(where: {$0.contains("Units")}) else { return XCTFail(errorMsg) }
        let actualSectionTitles = therapySettingsScreen.getSectionTitleValue
        
        for row in step.dataTable!.rows.dropFirst() {
            let sectionTitle = row[sectionIndex]
            let unitsValue = row[unitsIndex]
            
            XCTAssertTrue(
                actualSectionTitles.contains(sectionTitle),
                "Section \(sectionTitle) is not displayed."
            )
            
            if !unitsValue.isEmpty {
                switch sectionTitle {
                case "Glucose Safety Limit":
                    assertLabelContainsUnitValue(therapySettingsScreen.getGlucoseSafetyLimitValue, unitsValue)
                case "Correction Range":
                    assertLabelContainsUnitValue(therapySettingsScreen.getCorrectionRangeValue, unitsValue)
                case "Pre-Meal Range":
                    assertLabelContainsUnitValue(therapySettingsScreen.getPreMealPresetValue, unitsValue)
                case "Workout Range":
                    assertLabelContainsUnitValue(therapySettingsScreen.getWorkoutPresetValue, unitsValue)
                case "Carb Ratios":
                    assertLabelContainsUnitValue(therapySettingsScreen.getCarbRatioValue, unitsValue)
                case "Basal Rates":
                    let basalRates = therapySettingsScreen.getbasalRateValues
                    let unitsValues = unitsValue.split(separator: ",").map { String($0) }
                    for basalRate in basalRates {
                        assertLabelContainsUnitValue(basalRate, unitsValues[0])
                    }
                    assertLabelContainsUnitValue(therapySettingsScreen.getBaselRateTotalValue, unitsValues[1])
                case "Delivery Limits":
                    app.swipeUp()
                    let unitsValues = unitsValue.split(separator: ",").map { String($0) }
                    assertLabelContainsUnitValue(therapySettingsScreen.getMaxBasalRateValue, unitsValues[0])
                    assertLabelContainsUnitValue(therapySettingsScreen.getMaxBolusValue, unitsValues[1])
                case "Insulin Sensitivities":
                    let insulinSensitivities = therapySettingsScreen.getInsulinSensitivityUnitValues
                    for insulinSensitivity in insulinSensitivities {
                        assertLabelContainsUnitValue(insulinSensitivity, unitsValue)
                    }
                default: break
                }
            }
        }
    }
    
    Then("Prescription section displays Dr. name and date of prescription") { _, _ in
        let prescriptionDetails = therapySettingsScreen.getSectionDescriptiveValue[0]
        let descriptionText = prescriptionDetails.split(separator: ",").map { String($0) }
        
        XCTAssertTrue(
            contains4To8NumbersAnd2NonDigits(string: descriptionText[1]),
            "Prescription text '\(prescriptionDetails)' does not contain date."
        )
        XCTAssert(
            containsDrAndTwoWordsWithSingleSpaces(string: descriptionText[0]),
            "Prescription text '\(prescriptionDetails)' does not contain doctor's name."
        )
    }
    
    Then(/^possible actions are$/) { _, step in
        for action in step.dataTable!.rows {
            switch action[0] {
            case "<Back": XCTAssertTrue(onboardingScreen.backButtonExists)
            case "Close": XCTAssertTrue(onboardingScreen.closeButtonExists)
            case "Continue": XCTAssertTrue(onboardingScreen.continueButtonExists)
            default: XCTFail("Action '\(action[0])' is not implemented for verification yet.")
            }
        }
    }
    
    //MARK: Help Functions
    
    func assertLabelContainsUnitValue(_ label: String, _ unitsValue: String) {
        XCTAssertTrue(
            label.contains(unitsValue),
            "Label \(label) does not contain string \(unitsValue)"
        )
    }
    
    func contains4To8NumbersAnd2NonDigits(string: String) -> Bool {
        var numberOfNumbersOccurences = 0
        var numberOfDelimitrsOccurences = 0
        
        for char in string.trimmingCharacters(in: CharacterSet(charactersIn: " ")) {
            if char.isWholeNumber { numberOfNumbersOccurences += 1 }
            if char.isPunctuation { numberOfDelimitrsOccurences += 1 }
        }
        return  (4...8).contains(numberOfNumbersOccurences) && numberOfDelimitrsOccurences == 2
    }
    
    func containsDrAndTwoWordsWithSingleSpaces(string: String) -> Bool {
        // Regex: "Dr." followed by exactly one space, then two words separated by exactly one space.
        let pattern = #"Dr\.\s\b\w+\b\s\b\w+\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }

        let range = NSRange(location: 0, length: string.utf16.count)
        return regex.firstMatch(in: string, range: range) != nil
    }
}
