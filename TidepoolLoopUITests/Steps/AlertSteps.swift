//
//  AlertSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 18.03.2025.
//

import CucumberSwift
import CucumberSwiftExpressions
import LoopUITestingKit
import XCTest

func alertSteps() {
    let alert = Alerts(app: app)
    
    When("I acknowledge alert") { _, _ in
        if alert.getAlertFirstButtonText.contains("OK") { alert.tapAlertFirstButton() }
        else { alert.tapAlertSecondButton() }
    }
    
    Then(/^alert displays(| within 5 minutes)$/) { matches, step in
        let alertsMap = step.dataTable!.rows.map {
            row -> (key: String, value: String) in (key: row[0], value: row[1])
        }
        
        if !matches.1.isEmpty { alert.waitForAlertTitleExists(timeout: 300) }
        
        for alertItem in alertsMap {
            let actualAlertValue = switch alertItem.key {
            case "Title": alert.getAlertTitleText
            case "Body": alert.getAlertBodyText
            case "FirstButton": alert.getAlertFirstButtonText
            case "SecondButton": alert.getAlertSecondButtonText
            default: ""
            }
            
            if actualAlertValue.isEmpty {
                XCTFail("The alert parameter '\(alertItem.key)' is not supported by test framework yet.")
            }
            
            XCTAssertEqual(alertItem.value, actualAlertValue)
        }
    }
}
