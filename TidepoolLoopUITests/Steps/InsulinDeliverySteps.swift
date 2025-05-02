//
//  InsulinDeliverySteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 09.05.2025.
//

import CucumberSwift
import CucumberSwiftExpressions
import LoopUITestingKit
import XCTest

func insulinDeliverySteps() {
    let insulinDeliveryScreen = InsulinDeliveryScreen(app: app)
    
    // MARK: Verifications
    
    Then(/^latest temporary basal rate reflects the new (lower|normal) target range$/) { matches, _ in
        var tempBasalValues = insulinDeliveryScreen.getInsulinDeliveryBasalValues
        let tempBasalValuesCount = tempBasalValues.count
        
        while tempBasalValuesCount == tempBasalValues.count {
            sleep(10)
            tempBasalValues = insulinDeliveryScreen.getInsulinDeliveryBasalValues
        }
        
        let basalValuesDiff = tempBasalValues[0] - tempBasalValues[1]
        
        XCTAssertTrue(
            matches.1 == "lower" ? basalValuesDiff > 1 : basalValuesDiff < -1,
            "Basal rate \(tempBasalValues[0]) does not reflects new \(matches.1) target range. " +
            "Previous basal rate was \(tempBasalValues[1])"
        )
    }
    
    Then(/^modulation of Basal Rates displays$/) { _, _ in
        for label in insulinDeliveryScreen.getInsulinDeliveryRowsLabel {
            XCTAssertTrue(
                label.contains("Temp Basal") && label.contains("U/hr"),
                "Basal Rates modulations don't display."
            )
        }
    }
}
