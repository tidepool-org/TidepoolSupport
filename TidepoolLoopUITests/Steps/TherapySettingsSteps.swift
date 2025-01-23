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
    
    When(/^I navigate to (Glucose Safety Limit|Correction Range) (edit|educational) screen$/) { matches, _ in
        if onboardingScreen.yourSettingsButtonIsHittable {
            onboardingScreen.tapYourSettingsButton()
            onboardingScreen.tapForDurationYourSettingsTitle()
            onboardingScreen.tapConfirmSkipOnboarding()
            onboardingScreen.tapContinueYourSettingsButton()
            onboardingScreen.tapContinueButton()
            onboardingScreen.tapContinueButton()
        }
        
        switch matches.1 {
        case "Correction Range":
            therapySettingsScreen.tapConfirmSaveButton()
            if therapySettingsScreen.glucoseSafetyLimitAlertExists {
                therapySettingsScreen.tapContinueAlertButton()
            }
            if matches.2 == "edit" { onboardingScreen.tapContinueButton() }
        default:
            break
        }
    }
    
    When(/^I tap Edit$/) { _, _ in
        therapySettingsScreen.tapEditButton()
    }
    
    When(/^I tap Confirm Setting$/) { _, _ in
        therapySettingsScreen.tapConfirmSaveButton()
    }
    
    When(/^I confirm and save correction range$/) { _, _ in
        therapySettingsScreen.tapConfirmSaveButton()
        therapySettingsScreen.tapContinueAlertButton()
    }
    
    When(/^I tap Go Back in alert window$/) { _, _ in
        therapySettingsScreen.tapGoBackAlertButton()
    }
    
    When(/^I tap Continue$/) { _, _ in
        onboardingScreen.tapContinueButton()
    }
    
    When(/^I tap Continue in alert window$/) { _, _ in
        therapySettingsScreen.tapContinueAlertButton()
    }
    
    When(/^I navigate back$/) { _, _ in
        onboardingScreen.tapBackButton()
    }
    
    When(/^I navigate back to (.*) edit screen$/) { matches, _ in
        for attempt in 1...20 {
            if therapySettingsScreen.therapySettingsTitleTextExists {
                if therapySettingsScreen.getTherapySettingsTitleText != matches.1 {
                    onboardingScreen.tapBackButton()
                } else {
                    return
                }
            } else { onboardingScreen.tapBackButton() }
        }
    }
    
    When(/^I navigate to the Therapy Settings confirmation screen$/) { _, _ in
        var maxAttempts = 9
        
        while maxAttempts > 0 {
            onboardingScreen.tapContinueButton()
            therapySettingsScreen.tapConfirmSaveButton()
            if therapySettingsScreen.goBackAlertButtonExists { therapySettingsScreen.tapContinueAlertButton() }
            if therapySettingsScreen.therapySettingsTitleTextExists { break }
            maxAttempts -= 1
        }
    }
    
    When(/^I save settings and finish the onboarding$/) { _, _ in
        therapySettingsScreen.tapSaveSettingsButton()
        onboardingScreen.tapContinueYourSettingsButton()
        onboardingScreen.tapForDurationGettingToKnowTitle()
        onboardingScreen.tapConfirmSkipOnboarding()
        onboardingScreen.allowNotifications()
        onboardingScreen.allowCriticalAlerts()
        onboardingScreen.dontAllowHelthKitAuthorization()
    }
    
    When(/^I pair CGM simulator$/) { _, _ in
        homeScreen.tapHudGlucosePill()
        cgmScreens.tapActionSheetCgmSimulatorButton()
    }
    
    When(/^I pair Pump simulator$/) { _, _ in
        homeScreen.tapPumpPill()
        pumpScreens.tapActionSheetPumpSimulatorButton()
    }
    
    When(/^I tap Therapy Settings$/) { _, _ in
        settingsScreen.tapTherapySettingsButton()
    }
    
    When(/^I tap information circle$/) { _, _ in
        therapySettingsScreen.tapInfoCircleButton()
    }
    
    When(/^I tap Done$/) { _, _ in
        therapySettingsScreen.tapDoneButton()
    }
    
    When(/^I close information screen$/) { _, _ in
        onboardingScreen.tapCloseButton()
    }

    //MARK: Verifications
    
    Then(/^value for picker wheel(s|) (is|are) set to$/) { _, step in
        let tableHeader = step.dataTable!.rows[0]
        var expectedValuesMap = [String: String]()
        
        for (index, key) in tableHeader.enumerated() {
            expectedValuesMap[key] = step.dataTable!.rows[1][index]
        }

        for attribute in therapySettingsScreen.getPickerWheelsValues(attributeValues: tableHeader) {
            XCTAssertEqual(expectedValuesMap[attribute.key], attribute.value)
        }
    }
    
    Then(/^(\d+) item(s|) display(s|) in the list$/) { matches, _ in
        let nbOfScheduledItems = therapySettingsScreen.getNumberOfScheduledItems
        
        XCTAssertEqual(
            Int(matches.1),
            nbOfScheduledItems,
            "Number of scheduled items '\(nbOfScheduledItems)' is not equal to expected number '\(matches.1)'"
        )
    }
    
    Then(/^(.*) education screen displays$/) { matches, _ in
        XCTAssertEqual(String(matches.1), therapySettingsScreen.getTherapySettingsEducationTitleText)
    }
    
    Then(/^alert '(.*)' appears$/) { matches, _ in
        let alertExists = if matches.1 == "Save Glucose Safety Limit?" {
            therapySettingsScreen.glucoseSafetyLimitAlertExists
        } else if matches.1 == "Save Correction Range(s)?" {
            therapySettingsScreen.correctionRangeAlertTitleTextExists
        } else { false }
        
        alertExists ? XCTAssertTrue(alertExists) : XCTFail("Alert message '\(matches.1)' does not appear.")
    }
    
    Then(/^(Low|High) (Glucose Safety Limit|Correction Value) message appears with (red|orange) warning indicators$/) { matches, _ in
        XCTAssertEqual("\(matches.1) \(matches.2)", therapySettingsScreen.getGuardrailWarningValue)
                
        if matches.3 == "red" {
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
                    for correctionRangeValue in therapySettingsScreen.getCorrectionRangeValues {
                        assertLabelContainsUnitValue(correctionRangeValue, unitsValue)
                    }
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
    
    Then(/^Prescription section displays Dr. name and date of prescription$/) { _, _ in
        let prescriptionDetails = therapySettingsScreen.getSectionDescriptiveValue[0]
        let descriptionText = prescriptionDetails.split(separator: ", ").map { String($0) }
        
        XCTAssertEqual(
            "4/28/21",
            descriptionText[1]
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
