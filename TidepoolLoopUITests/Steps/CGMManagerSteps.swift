//
//  CGMManagerSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 21.11.2024.
//

import CucumberSwift
import LoopUITestingKit
import XCTest

func cGMManagerSteps() {
    let cgmManagerScreen = CGMManagerScreen(app: app)
    let navigationBar = NavigationBar(app: app)
    let homeScreen = HomeScreen(app: app)
    
    // MARK: Actions
    
    When("I close cgm manager") { _, _ in
        cgmManagerScreen.tapCgmSimulatorDoneButton()
    }
    
    When(/^I open CGM Simulator settings(| from Home screen)$/) { matches, _ in
        if matches.1 == " from Home screen" { homeScreen.tapHudGlucosePill() }
        cgmManagerScreen.tapForDurationCgmSimulatorSettings()
    }
    
    When("I setup CGM Simulator") { _, step in
        let cgmSettingsMap = step.dataTable!.rows.map {
            row -> (key: String, value: String) in (key: row[0], value: row[1])
        }
        let cgmKeysGroup = [
            "MeasurementFrequency", "GlucoseNoise", "WarningThreshold", "CriticalThreshold",
            "Constant", "PercentCompleted", "CgmLowerLimit", "CgmUpperLimit"
        ]
        
        for cgmAttribute in cgmSettingsMap {
            switch cgmAttribute.key {
            case "Model":
                switch cgmAttribute.value {
                case "Sine Curve":
                    let sineCurveKeys = ["BaseGlucose", "Amplitude","Period"]
                    
                    cgmManagerScreen.tapSineCurveCell()
                    for sineCurveKey in sineCurveKeys {
                        if let glucoseAttribute = cgmSettingsMap.first(where: { $0.key == sineCurveKey }) {
                            switch sineCurveKey {
                            case "BaseGlucose": cgmManagerScreen.tapBaseGlucoseCell()
                            case "Amplitude": cgmManagerScreen.tapAmplitudeCell()
                            case "BasePeriodGlucose": cgmManagerScreen.tapPeriodCell()
                            default: break
                            }
                            cgmManagerScreen.setSingleTextField(glucose: glucoseAttribute.value)
                            navigationBar.tapBackButton()
                        }
                    }
                    navigationBar.tapBackButton()
                case "Constant": cgmManagerScreen.tapConstantCell()
                default: break
                }
            case "MeasurementFrequency": cgmManagerScreen.tapMeasurementFrequencyCell()
            case "GlucoseNoise": cgmManagerScreen.tapGlucoseNoiseCell()
            case "BackfillGlucose":
                cgmManagerScreen.tapBackfillGlucoseCell()
                for _ in 1...3 {
                    if navigationBar.saveButtonExists {
                        break
                    } else {
                        navigationBar.tapBackButton()
                        cgmManagerScreen.tapBackfillGlucoseCell()
                    }
                }
                navigationBar.tapSaveButton()
            case "WarningThreshold": cgmManagerScreen.tapWarningThresholdCell()
            case "CriticalThreshold": cgmManagerScreen.tapCriticalThresholdCell()
            case "Trend":
                cgmManagerScreen.tapTrendCell()
                cgmManagerScreen.setGlucoseTrend(glucoseTrend: cgmAttribute.value)
                navigationBar.tapBackButton()
                navigationBar.tapBackButton()
                cgmManagerScreen.tapCgmSimulatorDoneButton()
            case "IssueAlert":
                cgmManagerScreen.tapIssueAlertsCell()
                cgmManagerScreen.issueAlert(alertName: cgmAttribute.value)
                if cgmAttribute.value == "Retract any alert above" { navigationBar.tapBackButton() }
            case "PercentCompleted": cgmManagerScreen.tapPercentCompletedCell()
            case "CgmLowerLimit": cgmManagerScreen.tapCgmLowerLimitCell()
            case "CgmUpperLimit":
                app.swipeUp()
                cgmManagerScreen.tapCgmUpperLimitCell()
            default: break
            }
            
            if cgmKeysGroup.contains(cgmAttribute.key) {
                cgmManagerScreen.setSingleTextField(glucose: cgmAttribute.value)
                navigationBar.tapBackButton()
            }
        }
    }
    
    // MARK: Verifications
    
    Then("cgm manager displays") { _, _ in
        XCTAssert(cgmManagerScreen.cgmSimulatorDisplayed)
    }
    
    Then(/^CGM lifecycle progress bar displays$/) { _, step in
        let progressBarValues = step.dataTable!.rows.map {
            row -> (key: String, value: String) in (key: row[0], value: row[1])
        }
        
        for progressBarValue in progressBarValues {
            switch progressBarValue.key {
            case "Progress": XCTAssertEqual(progressBarValue.value, homeScreen.getPercentCompletedProgressbarValue)
            case "State": XCTAssertEqual(progressBarValue.value, homeScreen.getPercentCompletedProgressbarState)
            default: XCTFail("Attribute '\(progressBarValue.key)' is not supported by test framework yet.")
            }
        }
    }
}
