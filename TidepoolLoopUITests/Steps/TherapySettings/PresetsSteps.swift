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
    let presetsScreen = PresetsScreen(app: app)
    let homeScreen = HomeScreen(app: app)
    let navigationBar = NavigationBar(app: app)
    let presetsOnboardingScreen = PresetsOnboardingScreen(app: app)
    
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
        presetsScreen.tapPresetPreMealText()
    }
    
    When(/^I update (.*) Preset Correction Range$/) { matches, step in
        var valuesMap = [String: String]()
        
        if homeScreen.carbsTabButtonisHittable {
            homeScreen.tapPresetsTabButton()
        }
        if presetsOnboardingScreen.presetsTrainingTitleTextExists {
            therapySettingsScreen.tapCloseButton()
        }
        
        for row in step.dataTable!.rows {
            valuesMap[row[0]] = row[1]
        }
        
        let maxSwipesCount = ((valuesMap["MinValue"]?.contains("lowest")) == true) ? 1 : 3
        
        
        presetsScreen.tapPresetCard(presetName: String(matches.1))
        presetsScreen.tapEditPresetButton()
        presetsScreen.tapCorrectionRangeButton()
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
        presetsScreen.tapSaveButton()
    }
    
    When(/^I open (Workout|Pre-Meal) Preset$/) { matches, _ in
        if homeScreen.carbsTabButtonisHittable {
            homeScreen.tapPresetsTabButton()
        }
        matches.1 == "Workout" ? presetsScreen.tapPresetWorkoutText() : presetsScreen.tapPresetPreMealText()
    }
    
    When(/^I tap (.*) Preset card$/) { matches, _ in
        presetsScreen.tapPresetCard(presetName: String(matches.1))
    }
    
    When(/^I start (.*) Preset$/) { matches, _ in
        if homeScreen.carbsTabButtonisHittable {
            homeScreen.tapPresetsTabButton()
        }
        if presetsOnboardingScreen.presetsTrainingTitleTextExists {
            therapySettingsScreen.tapCloseButton()
        }
        presetsScreen.tapPresetCard(presetName: String(matches.1))
        presetsScreen.tapStartPresetButton()
    }
    
    When("I tap Start Preset") { _, _ in
        presetsScreen.tapStartPresetButton()
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
        presetsScreen.tapAdjustPresetDurationButton()
        presetsScreen.setPresetDuration(minutesAdjustment: timeArray[1], hoursAdjustment: timeArray[0], amPm: timeArray[2])
        presetsScreen.tapSaveButton()
}
    
    When(/^I tap (Adjust Preset Duration|End Preset|Close) button$/) { matches, _ in
        switch matches.1 {
        case "Adjust Preset Duration": presetsScreen.tapAdjustPresetDurationButton()
        case "End Preset": presetsScreen.tapEndPresetButton()
        case "Close": presetsScreen.tapCloseButton()
        default: break
        }
    }
    
    //MARK: Verifications
    
    Then(/^(.*) Preset card displays$/) { matches, step in
        guard let dataTable = step.dataTable else {
            XCTFail("DataTable missing in step")
            return
        }

        let headerRow = dataTable.rows.first!
        let expectedRow = dataTable.rows.dropFirst().first!

        var expectedValues: [String: String] = [:]
        for (index, key) in headerRow.enumerated() {
            expectedValues[key] = expectedRow[index]
        }

        let presetName = String(matches.1) // "Active", "Pre-Meal", "Workout", etc.

        // Fetch actuals differently if preset is active
        var actualValues: [String: String] = [:]

        if presetName == "Active" {
            let activeCorrectionRange = presetsScreen.getActivePresetCorrectionRangeLabel().split(separator: "-").map { String($0) }
            actualValues["Name"] = presetsScreen.getActivePresetNameLabel()
            actualValues["MinValue"] = activeCorrectionRange[0]
            actualValues["MaxValue"] = activeCorrectionRange[1]
            actualValues["IsScheduled"] = presetsScreen.activePresetScheduledIconExists ? "Yes": "No"
            actualValues["OverallInsulin"] = presetsScreen.getActivePresetOverallInsulin()
        } else {
            // Use the named preset methods
            actualValues["Name"] = presetName

            let correctionRange = presetsScreen
                .getPresetCorrectionRangeLabel(forPresetName: presetName)
                .split(separator: "-")
                .map { String($0) }

            if correctionRange.count >= 2 {
                actualValues["MinValue"] = correctionRange[0]
                actualValues["MaxValue"] = correctionRange[1]  //.trimmingCharacters(in: .whitespaces)
            }

            // Add more fields as needed
            actualValues["IsScheduled"] = presetsScreen.presetScheduledIconExists(forPresetName: presetName) ? "Yes" : "No"
            actualValues["OverallInsulin"] = presetsScreen.getPresetOverallInsulin(forPresetName: presetName)
      }

        // Verify all expected headers are present in actuals
        for key in expectedValues.keys {
            guard let expected = expectedValues[key],
                  let actual = actualValues[key] else {
                XCTFail("Missing actual or expected value for \(key)")
                continue
            }

            XCTAssertTrue(
                actual.contains(expected),
                "Expected \(key) = '\(expected)', got '\(actual)'"
            )
        }
    }


    
    Then(/^Correction Range is set to value(|s)$/) { _, step in
        let adjusteRangeText = presetsScreen.getAdjustedCorrectionRangeText.components(separatedBy: "-")
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
            case "Correction Range": presetsScreen.getCorrectionRangePreviewAdjustedRangeText
            case "Warning": presetsScreen.getCorrectionRangePreviewWarningText
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
            presetsScreen.getPresetWorkoutTextYPosition : presetsScreen.getPresetPreMealTextYPosition
        
        XCTAssertTrue(
            presetsScreen.getAllPresetsTextYPosition > presetCardTextYPosition,
            "Workout card is displayed under the All Presets list."
        )
    }
    
    Then(/^Preset bottom tray displays duration "(.*)"$/) { matches, _ in
        let actualValue = presetsScreen.getPresetActionSheetActiveOnText
        
        XCTAssertEqual(String(matches.1), actualValue)
    }
    
    Then(/^Preset bottom tray (does not|does) display$/) { matches, _ in
        let isDisplayed = matches.1 == "does"
        
        XCTAssertTrue(
            presetsScreen.presetActionSheetActiveOnTextExists == isDisplayed,
            "Preset bottom tray \(isDisplayed ? "does not" : "does") displays."
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
    
    Then(/^Preset ends within "(\d+)" minute(|s)$/) { matches, _ in
        XCTAssertTrue(
            presetsScreen.presetHasEndedWithintDuration(duration: Double(matches.1)! * 60 + 5),
            "Workout Preset has not ended within specific time interval of '\(matches).1' minute(s)."
        )
    }
}
