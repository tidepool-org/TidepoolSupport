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
    
    When("I initiate premeal setup") { _, _ in
        homeScreen.tapPreMealButton()
    }
    
    When("I cancel premeal dialog") { _, _ in
        homeScreen.tapPreMealDialogCancelButton()
    }
    
    When("I tap (closed|open) loop icon") { matches, _ in
        matches[1] == "closed" ? homeScreen.tapLoopStatusClosed() : homeScreen.tapLoopStatusOpen()
    }
    
    When("I dismiss closed loop status alert") { _, _ in
        homeScreen.tapLoopStatusAlertDismissButton()
    }
    
    When("I open bolus setup") { _, _ in
        homeScreen.tapBolusEntry()
    }
    
    When("I open carb entry") { _, _ in
        homeScreen.tapCarbEntry()
    }
    
    When("I open pump manager") { _, _ in
        homeScreen.tapPumpPill()
    }
    
    // MARK: Verifications
    
    Then("(open|closed) loop displays") { matches, _ in
        if matches[1] == "closed" {
            XCTAssertTrue(homeScreen.hudStatusClosedLoopExists)
        } else {
            XCTAssert(homeScreen.hudStatusOpenLoopExists)
        }
    }
    
    Then("premeal button is (enabled|disabled)") { matches, _ in
        XCTAssertEqual(matches[1] == "enabled", homeScreen.preMealButtonEnabled)
    }
    
    Then("closed loop (on|off) alert displays") { matches, _ in
        XCTAssert(matches[1] == "on" ? homeScreen.closedLoopOnAlertTitleExists : homeScreen.closedLoopOffAlertTitleExists)
    }
    
    Then("pump pill displays value \"(.*?)\"") { matches, _ in
        XCTAssert(homeScreen.getPumpPillValue().contains(matches[1]))
    }
}
