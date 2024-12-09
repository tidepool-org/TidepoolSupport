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
    
    When("i close bolus screen") { _, _ in
        bolusScreen.tapCancelBolusButton()
    }
    
    When("i set bolus value {float}") { matches, _ in
        bolusScreen.tapBolusEntryTextField()
        bolusScreen.clearBolusEntryTextField()
        bolusScreen.setBolusEntryTextField(value: try String(matches.first(\.float)))
        bolusScreen.tapKeyboardDoneButton()
    }
    
    When("i deliver and authenticate bolus") { _, _ in
        bolusScreen.tapDeliverBolusButton()
        bolusScreen.setPasscode()
    }
    
    // MARK: Verifications
    
    Then("simple bolus calculator displays") { _, _ in
        XCTAssert(bolusScreen.simpleBolusCalculatorTitleExists)
    }
    
    Then("bolus screen displays") { _, _ in
        XCTAssert(bolusScreen.bolusTitleExists)
    }
}
