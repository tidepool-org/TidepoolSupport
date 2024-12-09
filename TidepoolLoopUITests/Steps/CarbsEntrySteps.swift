//
//  CarbsEntrySteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 23.11.2024.
//

import CucumberSwift
import LoopUITestingKit
import XCTest

func carbsEntrySteps() {
    let carbsEntryScreen = CarbsEntryScreen(app: app)
    
    // MARK: Actions
    
    When("I close carbs entry screen") { _, _ in
        carbsEntryScreen.tapCancelCarbsEntry()
    }
    
    // MARK: Verifications
    
    Then("simple meal calculator displays") { _, _ in
        XCTAssert(carbsEntryScreen.simpleMealCalculatorExists)
    }
    
    Then("carb entry screen displays") { _, _ in
        XCTAssert(carbsEntryScreen.carbEntryScreenExists)
    }
}
