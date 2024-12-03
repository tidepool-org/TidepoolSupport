//
//  CarbsEntrySteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 23.11.2024.
//

import XCTest
import CucumberSwift

func carbsEntrySteps() {
    let carbsEntryScreen = CarbsEntryScreen()
    
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
