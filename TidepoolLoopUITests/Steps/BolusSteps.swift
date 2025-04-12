//
//  BolusSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 23.11.2024.
//

import CucumberSwift
import CucumberSwiftExpressions
import LoopUITestingKit
import XCTest

func bolusSteps() {
    let bolusScreen = BolusScreen(app: app)
    
    // MARK: Actions
    
    When("I close bolus screen") { _, _ in
        bolusScreen.tapCancelBolusButton()
    }
    
    When("I set bolus value {float}") { matches, _ in
        bolusScreen.tapBolusEntryTextField()
        bolusScreen.clearBolusEntryTextField()
        bolusScreen.setBolusEntryTextField(value: try String(matches.first(\.float)).replacing(",", with: "."))
        bolusScreen.tapKeyboardDoneButton()
    }
    When("I set current glucose value {float}") {matches, _ in
        bolusScreen.tapCurrentGlucoseEntryTextField()
        bolusScreen.clearCurrentGlucoseEntryTextField()
        bolusScreen.setCurrentGlucoseEntryTextField(value: try String(matches.first(\.float)).replacing(",", with: "."))
        bolusScreen.tapKeyboardDoneButton()
    }
    
    When("I deliver and authenticate bolus") { _, _ in
        bolusScreen.tapBolusActionButton()
        bolusScreen.setPasscode()
    }

    

   
    
    
    
    // MARK: Verifications
    
    Then("simple bolus calculator displays") { _, _ in
        XCTAssert(bolusScreen.simpleBolusCalculatorTitleExists)
    }
    
    Then("bolus screen displays") { _, _ in
        XCTAssert(bolusScreen.bolusTitleExists)
    }
    
    Then("glucose range warning displays") { _, _ in
        XCTAssert(bolusScreen.glucoseEntryRangeWarningExists)
    }
    
    Then(/^bolus field displays value \"(.*?)\"$/) { matches, _ in
        XCTAssert(bolusScreen.getBolusFieldValue().contains(matches.1))
    }
}
