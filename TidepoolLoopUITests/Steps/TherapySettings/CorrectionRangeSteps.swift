//
//  CorrectionRangeSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 15.01.2025.
//

import CucumberSwift
import LoopUITestingKit
import XCTest

func correctionRangeSteps() {
    let therapySettingsScreen = TherapySettingsScreen(app: app)
    let onboardingScreen = OnboardingScreen(app: app)
    
    //MARK: Actions
    
    When(/^I add (\d+) new correction range schedule item(s)$/) { matches, _ in
        for _ in 1...Int(matches.1)! {
            therapySettingsScreen.tapAddButton()
            therapySettingsScreen.tapAddNewEntryButton()
        }
    }
    
    When(/^I add new (Correction Range|Carb Ratios) schedule item$/) { matches, step in
        let isCarbRatios = matches.1 == "Carb Ratios"
        var valuesMap = [String: String]()
        
        for (index, key) in step.dataTable!.rows[0].enumerated() {
            valuesMap[key] = step.dataTable!.rows[1][index]
        }
        
        therapySettingsScreen.tapAddButton()
        therapySettingsScreen.setScheduleItemValues(
            [
                (valuesMap["Time"] ?? "", 0),
                (valuesMap[isCarbRatios ? "WholeNumber" : "MinValue"] ?? "", 1),
                (valuesMap[isCarbRatios ? "Decimal" : "MaxValue"] ?? "", 2)
            ]
        )
        therapySettingsScreen.tapAddNewEntryButton()
    }
    
    When(/^I edit (\d+)(st|nd|rd|th) scheduled item of (Correction Range|Carb Ratios)$/) { matches, step in
        let isCarbRatios = matches.3 == "Carb Ratios"
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
                (valuesMap[isCarbRatios ? "WholeNumber" : "MinValue"] ?? "", 1),
                (valuesMap[isCarbRatios ? "Decimal" : "MaxValue"] ?? "", 2)
            ]
        )
    }
    
    When(/^I remove the (\d+)(st|nd|rd|th) item$/) { matches, _ in
        therapySettingsScreen.removeScheduleItem(itemIndex: Int(matches.1)! - 1)
    }
    
    
    //MARK: Verifications
    
    Then(/^(correction range|pre-meal preset|workout preset) of (\d+)(st|nd|rd|th) scheduled item displays values$/)
    { matches, step in
        let firstItemKey = matches.1 == "correction range" ? "Time" : "Title"
        let scheduledItemIndex = matches.1 != "correction range" ? nil : Int(matches.2)! - 1
        
        let scheduleItemText = therapySettingsScreen.getScheduleItemText(scheduledItemIndex)
        let scheduleItemKeys = [firstItemKey, "MinValue", "Delimiter", "MaxValue", "Units"]
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
    
    Then(/^(Correction|Pre-Meal|Workout) Values message appears with warning indicators$/) { matches, step in
        let tableHeader = step.dataTable!.rows[0]
        let tableData = step.dataTable!.rows[1]
        let messageIndicator = tableHeader.firstIndex(where: {$0.contains("MessageIndicator")})
        let minValIndex = tableHeader.firstIndex(where: {$0.contains("MinValue")})
        let maxValIndex = tableHeader.firstIndex(where: {$0.contains("MaxValue")})
        
        XCTAssertEqual("\(matches.1) Values", therapySettingsScreen.getGuardrailWarningValue)
        
        if messageIndicator != nil {
            let warningMessage = "warning triangle does not display."
            tableData[messageIndicator!] == "red" ?
            XCTAssertTrue(therapySettingsScreen.guardRailRedWarningTriangleImageExists, "Red \(warningMessage)") :
            XCTAssertTrue(therapySettingsScreen.guardRailOrangeWarningTriangleImageExists, "Orange \(warningMessage)")
        }
        
        if minValIndex != nil && maxValIndex != nil {
            let warningMessage = "warning triangle next to value text does not display"
            if tableData[minValIndex!] == tableData[maxValIndex!] {
                let numberOfImages = tableData[minValIndex!] == "red" ?
                therapySettingsScreen.getNumberOfnextToTextWarningTriangleRedImages :
                therapySettingsScreen.getNumberOfnextToTextWarningTriangleOrangeImages
                XCTAssertTrue(numberOfImages == 2, "\(tableData[minValIndex!]) \(warningMessage)")
            } else {
                let orderWarning = "Red warning triangle does not display for"
                
                XCTAssertTrue(therapySettingsScreen.nextToTextWarningTriangleRedImageExists, "Red \(warningMessage)")
                XCTAssertTrue(therapySettingsScreen.nextToTextWarningTriangleOrangeImageExists, "Orange \(warningMessage)")
                
                if tableData[minValIndex!] == "red" {
                    XCTAssertTrue(
                        therapySettingsScreen.getXPositionOfnextToTextWarningTriangleRedImages <
                        therapySettingsScreen.getXPositionOfnextToTextWarningTriangleOrangeImages,
                        "\(orderWarning) minimal value."
                    )
                } else {
                    XCTAssertTrue(
                        therapySettingsScreen.getXPositionOfnextToTextWarningTriangleRedImages >
                        therapySettingsScreen.getXPositionOfnextToTextWarningTriangleOrangeImages,
                        "\(orderWarning) maximal value."
                    )
                }
            }
        } else if minValIndex != nil || maxValIndex != nil {
            let warningImageSeverity = minValIndex != nil ? tableData[minValIndex!] : tableData[maxValIndex!]
            
            warningImageSeverity == "red" ?
            XCTAssertTrue(therapySettingsScreen.nextToTextWarningTriangleRedImageExists) :
            XCTAssertTrue(therapySettingsScreen.nextToTextWarningTriangleOrangeImageExists)
        }
    }
    
    Then(/^(Correction Range|Pre-Meal Preset|Workout Preset) section on Therapy Settings screen displays$/)
    { matches, step in
        let firstItemKey = matches.1 == "Correction Range" ? "Time" : "Title"
        let tableHeader = step.dataTable!.rows[0]
        let tableData = step.dataTable!.rows.dropFirst()
        let scheduleItemTexts = switch matches.1 {
        case "Correction Range": therapySettingsScreen.getCorrectionRangeValues
        case "Pre-Meal Preset": [therapySettingsScreen.getPreMealPresetValue]
        case "Workout Preset": [therapySettingsScreen.getWorkoutPresetValue]
        default: [""]
        }
        let scheduleItemKeys = [firstItemKey, "MinValue", "Delimiter", "MaxValue", "Units"]
        var scheduleItemValues = [String]()
        var expectedValuesMap = [String: [String]]()
        var actualValuesMap = [String: [String]]()
        
        if scheduleItemTexts == [""] { XCTFail("Section '\(matches.1)' is not supported by test framework yet.") }
        
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
