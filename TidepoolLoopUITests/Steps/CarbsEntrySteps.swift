//
//  CarbsEntrySteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 23.11.2024.
//

import XCTest

class CarbsEntrySteps {
    let carbsEntryScreen = CarbsEntryScreen()
    
    // MARK: Actions
    
    func when_i_close_carbs_entry_screen() {
        carbsEntryScreen.tapCancelCarbsEntry()
    }
    
    // MARK: Verifications
    
    func then_simple_meal_calculator_displays() {
        XCTAssert(carbsEntryScreen.simpleMealCalculatorExists)
    }
    
    func then_carb_entry_screen_displays() {
        XCTAssert(carbsEntryScreen.carbEntryScreenExists)
    }
}
