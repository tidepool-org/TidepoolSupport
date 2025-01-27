//
//  PreMealPresetSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 22.01.2025.
//

import CucumberSwift
import LoopUITestingKit
import XCTest

func preMealPreset() {
    let therapySettingsScreen = TherapySettingsScreen(app: app)
    let presetScreen = PresetsScreen(app: app)
    
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
}
