//
//  HomeSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 19.11.2024.
//

import CucumberSwift
import CucumberSwiftExpressions
import LoopUITestingKit
import XCTest

func homeSteps() {
    let homeScreen = HomeScreen(app: app)
    
    // MARK: Actions
    
    When("I open settings") { _, _ in
        homeScreen.tapSettingsButton()
    }
    
    When("I open Presets") { _, _ in
        homeScreen.tapPresetsTabButton()
    }
    
    When("I open CGM manager") { _, _ in
        homeScreen.tapHudGlucosePill()
    }
    
    When(/^I tap (closed|open) loop icon$/) { matches, _ in
        matches.1 == "closed" ? homeScreen.tapLoopStatusClosed() : homeScreen.tapLoopStatusOpen()
    }
    
    When("I dismiss closed loop status alert") { _, _ in
        homeScreen.tapLoopStatusAlertDismissButton()
    }
    
    When("I open bolus setup") { _, _ in
        homeScreen.tapBolusEntry()
    }
    
    When("I open Carb Entry") { _, _ in
        homeScreen.tapCarbEntry()
    }
    
    When("I open Active Carbohydrates details") { _, _ in
        homeScreen.tapNavigateToActiveCarbsDetails()
    }
    
    When("I open pump manager") { _, _ in
        homeScreen.tapPumpPill()
    }
    When("I tap on tap to stop") { _, _ in
        homeScreen.taptapToStop()
    }
    When("I tap on tap to resume") { _, _ in
        homeScreen.tapinsulinTapToResumeCell()
    }
    
    // MARK: Verifications
    
    Then(/^glucose chart (allows|doesn't allow) navigation to detailed view$/) { matches, _ in
        XCTAssertTrue((matches.1 == "doesn't allow") == homeScreen.navigationToGlucoseDetailsIsDisabled)
    }
    
    Then(/^(open|closed) loop displays$/) { matches, _ in
        if matches.1 == "closed" {
            XCTAssertTrue(homeScreen.hudStatusClosedLoopExists)
        } else {
            sleep(3)
            XCTAssert(homeScreen.hudStatusOpenLoopExists)
        }
    }
    
    Then(/^closed loop (on|off) alert displays$/) { matches, _ in
        XCTAssert(matches.1 == "on" ? homeScreen.closedLoopOnAlertTitleExists : homeScreen.closedLoopOffAlertTitleExists)
    }
    
    Then(/^pump pill displays value \"(.*?)\"$/) { matches, _ in
        XCTAssert(homeScreen.getPumpPillValue().contains(matches.1))
    }
    
    Then(/^cgm pill (doesn't display|displays) (value|trend|alert) \"(.*?)\"$/) { matches, _ in
        let expectedValue = String(matches.3)
        let actualValue = switch matches.2 {
        case "value": homeScreen.getHudGlucosePillValue()[0].components(separatedBy: " ")[0]
        case "trend": homeScreen.getHudGlucosePillValue()[1]
        case "alert": homeScreen.getHudGlucosePillValue()[0]
        default: ""
        }
        
        XCTAssertEqual(
            expectedValue == actualValue,
            matches.1 == "displays",
            "Comparison of expected \(matches.2) value '\(expectedValue)' and actual value '\(actualValue)' should be" +
            " \(matches.1 == "displays") but was \(!(matches.1 == "displays"))"
        )
    }
    
    Then("temporary status bar displays current bolus progress") { _, _ in
        XCTAssertTrue(homeScreen.bolusProgressTextExists, "Temporary status bar with bolus progress is not displayed.")
        XCTAssertTrue(homeScreen.tapToStopTextExists, "'Tap to Stop' option is not available on temporary status bar.")
    }
    
    Then(/^Active Carbohydrates displays value "(.*)"$/) { matches, _ in        
        XCTAssertEqual(String(matches.1), homeScreen.getActiveCarbsValue)
    }

Then("Bolus delivery temporary status bar displays") { _, _ in
        XCTAssert(homeScreen.bolusProgressTextExists)
    }
    
    Then("Bolus delivery canceled and status bar dismisses") { _, _ in
        XCTAssert(homeScreen.bolusCanceledTextExists)
        XCTAssert(homeScreen.bolusCanceledTextNotExists)
    }
    Then("Insulin suspended temporary status bar displays") { _, _ in
     //   XCTAssert(homeScreen.insulinSuspendedCellExists)
        XCTAssert(homeScreen.insulinTapToResumeCellExists)
    }
    
    Then("Insulin suspended status bar dismisses") { _, _ in
        XCTAssert(homeScreen.insulinSuspendedCellNotExists)
    }
}
