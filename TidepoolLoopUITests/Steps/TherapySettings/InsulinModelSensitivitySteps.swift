//
//  InsulinModel.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 25.02.2025.
//

import CucumberSwift
import LoopUITestingKit
import XCTest

func insulinModelSensitivitySteps() {
    let therapySettingsScreen = TherapySettingsScreen(app: app)
    
    When(/^I edit (\d+)(st|nd|rd|th) scheduled item of Insulin Sensitivity$/) { matches, step in
        var valuesMap = [String: String]()
        
        for (index, key) in step.dataTable!.rows[0].enumerated() {
            valuesMap[key] = step.dataTable!.rows[1][index]
        }
        
        if !therapySettingsScreen.pickerWheelExists {
            therapySettingsScreen.tapScheduleItem(Int(matches.1)! - 1)
        }
        
        therapySettingsScreen.setScheduleItemValues(
            [
                (valuesMap["Time"] ?? "", 0),
                (valuesMap["Value"] ?? "", 1),
            ]
        )
    }
    
    When(/^I add new Insulin Sensitivity schedule item$/) { _, step in
        var valuesMap = [String: String]()
        
        for (index, key) in step.dataTable!.rows[0].enumerated() {
            valuesMap[key] = step.dataTable!.rows[1][index]
        }
        
        therapySettingsScreen.tapAddButton()
        therapySettingsScreen.setScheduleItemValues(
            [
                (valuesMap["Time"] ?? "", 0),
                (valuesMap["Value"] ?? "", 1),
            ]
        )
        therapySettingsScreen.tapAddNewEntryButton()
    }
    
    When(/^I select Rapid-Acting – (Children|Adults) insulin model$/) { matches, _ in
        if (matches.1 == "Adults") {
            therapySettingsScreen.tapRapidActingAdults()
        } else {
            therapySettingsScreen.tapRapidActingChildren()
        }
    }
    
    Then(/^Insulin Model section on Therapy Settings screen displays$/) { _, step in
        let insulinModelValue = step.dataTable!.rows[1][0]
        let actualValue = therapySettingsScreen.getInsulinModelTitleValue
        
        XCTAssertTrue(
            actualValue.contains(insulinModelValue),
            "Displayed label '\(actualValue)' does not contain '\(insulinModelValue)'"
        )
    }
    
    Then(/^Insulin Sensitivity of (\d+)(st|nd|rd|th) scheduled item displays values$/) { matches, step in
        let scheduledItemIndex = Int(matches.1)! - 1
        let scheduleItemText = therapySettingsScreen.getScheduleItemText(scheduledItemIndex)
        let scheduleItemKeys = ["Time", "Value"]
        let scheduleItemValues = scheduleItemText.split(separator: ", ")
        var actualValues = [String: String]()
        var expectedValues = [String: String]()
        
        for (index, key) in step.dataTable!.rows[0].enumerated() {
            expectedValues[key] = step.dataTable!.rows[1][index]
        }
        for (index, key) in scheduleItemKeys.enumerated() {
            actualValues[key] = String(scheduleItemValues[index])
        }
        for expectedValue in expectedValues {
            XCTAssertEqual(expectedValue.value, actualValues[expectedValue.key])
        }
    }
}
