//
//  BasalRates.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 20.02.2025.
//

import CucumberSwift
import LoopUITestingKit
import XCTest

func basalRatesSteps() {
    let therapySettingsScreen = TherapySettingsScreen(app: app)
    
    When(/^I edit item of (Maximum Basal Rate|Maximum Bolus)$/) { matches, step in
        var valuesMap = [String: String]()
        
        for (index, key) in step.dataTable!.rows[0].enumerated() {
            valuesMap[key] = step.dataTable!.rows[1][index]
        }
        
        if !therapySettingsScreen.pickerWheelExists {
            matches.1 == "Maximum Bolus" ?
                therapySettingsScreen.tapMaxBolusItem() : therapySettingsScreen.tapMaxBasalRateItem()
        }
        therapySettingsScreen.setScheduleItemValues(
            [
                (valuesMap["WholeNumber"] ?? "", 0),
                (valuesMap["Decimal"] ?? "", 1)
            ]
        )
    }
}
