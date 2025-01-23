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
    
    When("I add new correction range schedule item") { _, step in
        let tableHeader = step.dataTable!.rows[0]
        let tableData = step.dataTable!.rows[1]
        guard let timeIndex = tableHeader.firstIndex(where: {$0.contains("Time")}) else {
            return XCTFail("'Time' attribute not set.")
        }
        guard let minValIndex = tableHeader.firstIndex(where: {$0.contains("MinValue")}) else {
            return XCTFail("'MinValue' attribute not set.")
        }
        guard let maxValIndex = tableHeader.firstIndex(where: {$0.contains("MaxValue")}) else {
            return XCTFail("'MaxValue' attribute not set.")
        }
        
        therapySettingsScreen.tapAddButton()
        therapySettingsScreen.setScheduleItemValues(time: tableData[timeIndex], minValue: tableData[minValIndex], maxValue: tableData[maxValIndex])
        therapySettingsScreen.tapAddNewEntryButton()
    }
    
    When(/^I edit (\d+)(st|nd|rd|th) scheduled item$/) { matches, step in
        var valuesMap = [String: String]()
        
        for (index, key) in step.dataTable!.rows[0].enumerated() {
            valuesMap[key] = step.dataTable!.rows[1][index]
        }
        
        if !therapySettingsScreen.pickerWheelExists {
            therapySettingsScreen.tapScheduleItem(itemIndex: Int(matches.1)! - 1)
        }
        therapySettingsScreen.setScheduleItemValues(
            time: valuesMap["Time"] ?? "",
            minValue: valuesMap["MinValue"] ?? "",
            maxValue: valuesMap["MaxValue"] ?? ""
        )
    }
    
    When(/^I remove the (\d+)(st|nd|rd|th) item$/) { matches, _ in
        therapySettingsScreen.removeScheduleItem(itemIndex: Int(matches.1)! - 1)
    }
    
    
    //MARK: Verifications
    
    Then(/^correction range of (\d+)(st|nd|rd|th) scheduled item displays values$/) { matches, step in
        let scheduleItemText = therapySettingsScreen.getScheduleItemText(itemIndex: Int(matches.1)! - 1)
        let scheduleItemKeys = ["Time", "MinValue", "Delimiter", "MaxValue", "Units"]
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
    
    Then(/^Correction Values message appears with warning indicators$/) { _, step in
        let tableHeader = step.dataTable!.rows[0]
        let tableData = step.dataTable!.rows[1]
        let messageIndicator = tableHeader.firstIndex(where: {$0.contains("MessageIndicator")})
        let minValIndex = tableHeader.firstIndex(where: {$0.contains("MinValue")})
        let maxValIndex = tableHeader.firstIndex(where: {$0.contains("MaxValue")})
        
        XCTAssertEqual("Correction Values", therapySettingsScreen.getGuardrailWarningValue)
        
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
    
    Then(/^Correction Range information screen displays with possible actions$/) { _, step in
        XCTAssertTrue(therapySettingsScreen.correctionRangeInformationTextExists)
        
        for action in step.dataTable!.rows {
            switch action[0] {
            case "Close": XCTAssertTrue(onboardingScreen.closeButtonExists)
            default: XCTFail("Action '\(action[0])' is not implemented for verification yet.")
            }
        }
    }
    
    Then(/^Correction Range edit screen displays with possible actions$/) { _, step in
        for action in step.dataTable!.rows {
            switch action[0] {
            case "<Back": XCTAssertTrue(onboardingScreen.backButtonExists)
            case "Edit": XCTAssertTrue(therapySettingsScreen.editButtonExists)
            case "Add": XCTAssertTrue(therapySettingsScreen.addButtonExists)
            case "Confirm Setting": XCTAssertTrue(therapySettingsScreen.confirmSaveButtonExists)
            case "Information": XCTAssertTrue(therapySettingsScreen.infoCircleButtonExists)
            default: XCTFail("Action '\(action[0])' is not implemented for verification yet.")
            }
        }
    }
    
    Then(/^Correction Range section on Therapy Settings screen displays$/) { _, step in
        let tableHeader = step.dataTable!.rows[0]
        let scheduleItemTexts = therapySettingsScreen.getCorrectionRangeValues
        let scheduleItemKeys = ["Time", "MinValue", "Delimiter", "MaxValue", "Units"]
        var scheduleItemValues = [String]()
        var expectedValuesMap = [String: [String]]()
        var actualValuesMap = [String: [String]]()
        
        for (index, key) in tableHeader.enumerated() {
            var arrayValue = [String]()
            
            for row in step.dataTable!.rows.dropFirst() {
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
            for index in 0..<expectedValuesMap.count {
                let expectedValue = expectedValuesMap[key]![index]
                
                if expectedValue != "nil" {
                    XCTAssertEqual(expectedValue, actualValuesMap[key]![index])
                }
            }
        }
    }
    
}
