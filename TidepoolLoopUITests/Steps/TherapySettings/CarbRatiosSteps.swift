//
//  CarbRatiosSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 07.02.2025.
//

import CucumberSwift
import LoopUITestingKit
import XCTest

func carbRatiosSteps() {
    let therapySettingsScreen = TherapySettingsScreen(app: app)
    
    //MARK: Verifications
    
    Then(/^Carb Ratios of (\d+)(st|nd|rd|th) scheduled item displays values$/) { matches, step in
        let scheduledItemIndex = Int(matches.1)! - 1
        let scheduleItemText = therapySettingsScreen.getScheduleItemText(scheduledItemIndex)
        let scheduleItemKeys = ["Time", "Value", "Units"]
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
    
    Then(/^Carb Ratios message appears with warning indicators$/) { _, step in
        let tableHeader = step.dataTable!.rows[0]
        var nextToTextWarnings = therapySettingsScreen.getNextToTextWarningTriangleImages
        var tableData = step.dataTable!.rows[1]
        var messageIndicator: String? = nil
        var indexReducer = 0
        
        if tableHeader.contains("MessageIndicator") {
            messageIndicator = tableData.remove(at: tableHeader.firstIndex(of: "MessageIndicator")!)
        }
            
        XCTAssertEqual("Carb Ratios", therapySettingsScreen.getGuardrailWarningValue)
        
        if messageIndicator != nil {
            let warningMessage = "warning triangle does not display."
            messageIndicator == "red" ?
            XCTAssertTrue(therapySettingsScreen.guardRailRedWarningTriangleImageExists, "Red \(warningMessage)") :
            XCTAssertTrue(therapySettingsScreen.guardRailOrangeWarningTriangleImageExists, "Orange \(warningMessage)")
        }
        
        for (index, scheduleItem) in tableData.enumerated() {
            let warningMessage = "'\(scheduleItem)' warning triangle does not display."
            
            switch String(scheduleItem) {
            case "red":
                XCTAssertTrue(nextToTextWarnings[index - indexReducer].lowercased().contains("red"), warningMessage)
            case "orange":
                XCTAssertTrue(nextToTextWarnings[index - indexReducer].lowercased().contains("orange"), warningMessage)
            case "none":
                indexReducer += 1
                XCTAssertTrue(
                    therapySettingsScreen.getNumberOfnextToTextWarningTriangleRedImages +
                    therapySettingsScreen.getNumberOfnextToTextWarningTriangleOrangeImages +
                    indexReducer == tableData.count
                )
            default: XCTFail("Warning triangle could only have values 'red', 'orange' or 'none'.")
            }
        }
    }
    
    Then(/^Carb Ratios section on Therapy Settings screen displays$/) { _, step in
        let tableHeader = step.dataTable!.rows[0]
        let tableData = step.dataTable!.rows.dropFirst()
        let scheduleItemTexts = therapySettingsScreen.getCarbRatiosValues
        let scheduleItemKeys = ["Time", "Value", "Units"]
        var scheduleItemValues = [String]()
        var expectedValuesMap = [String: [String]]()
        var actualValuesMap = [String: [String]]()
                
        for (index, key) in tableHeader.enumerated() {
            var arrayValue = [String]()
            
            for row in tableData {
                arrayValue.append(row[index].isEmpty ? "nil" : row[index])
            }
            expectedValuesMap[key] = arrayValue
        }
        for (index, key) in scheduleItemKeys.enumerated() {
            var arrayValue = [String]()
            
            for item in scheduleItemTexts {
                arrayValue.append(String(item.split(separator: ", ")[index]))
            }
            actualValuesMap[key] = arrayValue
        }
        for key in tableHeader {
            for index in 0..<tableData.count {
                let expectedValue = expectedValuesMap[key]![index]
                
                if expectedValue != "nil" {
                    XCTAssertEqual(expectedValue, actualValuesMap[key]![index])
                }
            }
        }
    }
}
