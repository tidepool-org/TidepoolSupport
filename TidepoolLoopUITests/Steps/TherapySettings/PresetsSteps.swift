//
//  PreMealPresetSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 22.01.2025.
//

import CucumberSwift
import LoopUITestingKit
import XCTest

func presetsSteps() {
    let therapySettingsScreen = TherapySettingsScreen(app: app)
    let presetScreen = PresetsScreen(app: app)
    let homeScreen = HomeScreen(app: app)
    let navigationBar = NavigationBar(app: app)
    
    //MARK: Actions
    
    When(/^I edit (\d+)(st|nd|rd|th) scheduled item of (Pre-Meal|Workout) Preset$/) { matches, step in
        let tableHeader = step.dataTable!.rows[0]
        let tableData = step.dataTable!.rows[1]
        let maxSwipes = (matches.3 == "Workout" && tableData.contains("highest")) ? 6 : 3
        var valuesMap = [String: String]()
        var scheduleItemValues = [(value: String, pickerWheel: Int)]()
        
        for (index, key) in tableHeader.enumerated() {
            valuesMap[key] = tableData[index]
        }
        
        if !therapySettingsScreen.pickerWheelExists {
            therapySettingsScreen.tapScheduleItem()
        }
        
        scheduleItemValues.append((valuesMap[tableHeader[0]] ?? "", tableHeader[0] == "MinValue" ? 0 : 1))
        if tableHeader.count > 1 {
            scheduleItemValues.append((valuesMap[tableHeader[1]] ?? "", tableHeader[1] == "MinValue" ? 0 : 1))
        }
        
        therapySettingsScreen.setScheduleItemValues(scheduleItemValues, maxSwipes)
    }
    
    When("I open Pre-Meal correction range") { _, _ in
        presetScreen.tapPresetPreMealText()
    }
    
    When(/^I update Pre-Meal Correction Range$/) { _, step in
        var valuesMap = [String: String]()
        
        if homeScreen.carbsTabButtonisHittable {
            homeScreen.tapPresetsTabButton()
            presetScreen.tapPresetPreMealText()
        }
        
        for row in step.dataTable!.rows {
            valuesMap[row[0]] = row[1]
        }
        
        let maxSwipesCount = ((valuesMap["MinValue"]?.contains("lowest")) == true) ? 1 : 3
        
        if !valuesMap.keys.contains("MinValue") && !valuesMap.keys.contains("MaxValue") {
            XCTFail("At least one parameter 'MinValue' or 'MaxValue' must be set. Other parameters are not supported.")
        }
        
        presetScreen.tapEditPresetButton()
        presetScreen.tapCorrectionRangeButton()
        therapySettingsScreen.setScheduleItemValues(
            [
                (valuesMap["MinValue"] ?? "", 0),
                (valuesMap["MaxValue"] ?? "", 1)
            ],
            maxSwipesCount
        )
    }
    
    When("I dismiss Presets") { _, _ in
        app.swipeDown(velocity: .fast)
        if navigationBar.doneButtonExists { navigationBar.tapDoneButton() }
    }
    
    When("I tap Save") { _, _ in
        presetScreen.tapSaveButton()
    }
    
    When(/^I open (Workout|Pre-Meal) Preset$/) { matches, _ in
        if homeScreen.carbsTabButtonisHittable {
            homeScreen.tapPresetsTabButton()
        }
        matches.1 == "Workout" ? presetScreen.tapPresetWorkoutText() : presetScreen.tapPresetPreMealText()
    }
    
    When("I tap Workout Preset card") { _, _ in
        presetScreen.tapPresetWorkoutText()
    }
    
    When("I tap Start Preset") { _, _ in
        presetScreen.tapStartPresetButton()
    }
    
    When(/^I adjust Preset Duration to "(.*)"$/) { matches, _ in
        var timeArray: [String]
        
        if matches.1.rangeOfCharacter(from: CharacterSet(charactersIn: "+-")) != nil {
            let timeAdjustment = Double(matches.1.components(separatedBy: " ")[0])!
            let adjustedTime = TestHelper.addIntervalAndFormat(seconds: timeAdjustment * 60) // timeAdjustment in minutes
            timeArray = [adjustedTime.hour, adjustedTime.minute, adjustedTime.ampm]
        } else {
            timeArray = matches.1.components(separatedBy: CharacterSet(charactersIn: ": "))
        }
        
        if timeArray.count != 3 { XCTFail("Time has to be set in format 'H:MM a'.") }
        if timeArray[1].count == 1 { timeArray[1] = "0\(timeArray[1])" }
        presetScreen.tapAdjustPresetDurationButton()
        presetScreen.setPresetDuration(minutesAdjustment: timeArray[1], hoursAdjustment: timeArray[0], amPm: timeArray[2])
        presetScreen.tapSaveButton()
}
    
    When(/^I tap (Adjust Preset Duration|End Preset|Close) button$/) { matches, _ in
        switch matches.1 {
        case "Adjust Preset Duration": presetScreen.tapAdjustPresetDurationButton()
        case "End Preset": presetScreen.tapEndPresetButton()
        case "Close": presetScreen.tapCloseButton()
        default: break
        }
    }
    
    //MARK: Verifications
    
    Then(/^(Pre-Meal|Workout) Preset section on Presets screen displays$/) { matches, step in
        let rowHeader = step.dataTable!.rows[0]
        let rowData = step.dataTable!.rows[1]
        let actualValuesHeader = ["MinValue", "MaxValue"]
        let actualValues =
        (
            matches.1 == "Pre-Meal" ?
            presetScreen.getPreMealCorrectionRangeText :
                presetScreen.getWorkoutCorrectionRangeText
        ).split(separator: "-").map { String ($0) }
        var expectedValuesMap = [String: String]()
        var actualValuesMap = [String: String]()
        
        for key in rowHeader {
            if !actualValuesHeader.contains(key) {
                XCTFail("Datatable must contains header titles: 'MinValue', 'MaxValue'")
            }
        }
        
        for (index, key) in actualValuesHeader.enumerated() {
            actualValuesMap[key] = actualValues[index]
        }
        for (index, key) in rowHeader.enumerated() { expectedValuesMap[key] = rowData[index] }
        for key in expectedValuesMap.keys {
            XCTAssert(
                actualValuesMap[key]!.contains(expectedValuesMap[key]!),
                "Actual value '\(String(actualValuesMap[key]!))' does not contain \(expectedValuesMap[key]!)"
            )
        }
    }
    
    Then(/^Correction Range is set to value(|s)$/) { _, step in
        let adjusteRangeText = presetScreen.getAdjustedCorrectionRangeText.components(separatedBy: "-")
        var expectedDictionary = [String: String]()
        var actualValuesDictionary = [String: String]()
                
        for row in step.dataTable!.rows {
            expectedDictionary[row[0]] = row[1]
        }
        
        actualValuesDictionary["MinValue"] = adjusteRangeText[0]
        actualValuesDictionary["MaxValue"] = adjusteRangeText[1]

        for expectedDictionaryItem in expectedDictionary {
            XCTAssertEqual(expectedDictionaryItem.value, actualValuesDictionary[expectedDictionaryItem.key])
        }
    }
    
    Then(/^Pre-Meal Presets preview displays$/) { _, step in
        let presetsMap = step.dataTable!.rows.map {
            row -> (key: String, value: String) in (key: row[0], value: row[1])
        }
        
        for presetsItem in presetsMap {
            let actualValue = switch presetsItem.key {
            case "Correction Range": presetScreen.getCorrectionRangePreviewAdjustedRangeText
            case "Warning": presetScreen.getCorrectionRangePreviewWarningText
            default: ""
            }
            
            if actualValue.isEmpty { XCTFail("Parameter \(presetsItem.key) is not supported by the test framework yet.") }
            
            XCTAssert(
                actualValue.contains(presetsItem.value),
                "Actual \(presetsItem.key) value '\(actualValue)' doesn't contain '\(presetsItem.value)'."
            )
        }
    }
    
    Then(/^(Workout|Pre-Meal) card moves above the All Presets list$/) { matches, _ in
        let presetCardTextYPosition = matches.1 == "Workout" ?
            presetScreen.getPresetWorkoutTextYPosition : presetScreen.getPresetPreMealTextYPosition
        
        XCTAssertTrue(
            presetScreen.getAllPresetsTextYPosition > presetCardTextYPosition,
            "Workout card is displayed under the All Presets list."
        )
    }
    
    Then(/^Workout Preset bottom tray displays duration "(.*)"$/) { matches, _ in
        let actualValue = presetScreen.getPresetActionSheetActiveOnText
        
        XCTAssertEqual(String(matches.1), actualValue)
    }
    
    Then(/^(Workout|Pre-Meal) Preset bottom tray (does not|does) display$/) { matches, _ in
        let isDisplayed = matches.2 == "does"
        
        XCTAssertTrue(
            presetScreen.presetActionSheetActiveOnTextExists == isDisplayed,
            "\(matches.1) Preset bottom tray \(isDisplayed ? "does not" : "does") displays."
        )
    }
    
    Then(/^Presets toolbar icon displays as (reverse|normal) icon$/) { matches, _ in
        let correctIconDisplayed = matches.1 == "normal" ?
            homeScreen.presetsToolbarImageExists : homeScreen.presetsSelectedToolbarImageExists
        
        XCTAssertTrue(
            correctIconDisplayed,
            "Preset toolbar displays '\(matches.1 == "normal" ? "normal" : "reverse")' icon but expected was '\(matches.1)'."
        )
    }
    
    Then(/^Workout Preset ends within "(\d+)" minute(|s)$/) { matches, _ in
        XCTAssertTrue(
            presetScreen.presetHasEndedWithintDuration(duration: Double(matches.1)! * 60 + 5),
            "Workout Preset has not ended within specific time interval of '\(matches).1' minute(s)."
        )
    }
}
