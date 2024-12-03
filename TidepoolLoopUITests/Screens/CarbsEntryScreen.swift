//
//  CarbsEntryScreen.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 23.11.2024.
//

import XCTest

class CarbsEntryScreen {
    
    // MARK: Elements
    
    private let simpleMealCalculatorTitleText = app.navigationBars.staticTexts["Simple Meal Calculator"]
    private let cancelCarbsEntryButton = app.navigationBars.buttons["Cancel"]
    private let carbEntryTitleText = app.navigationBars.staticTexts["Add Carb Entry"]
    
    // MARK: Actions
    
    func tapCancelCarbsEntry() {
        cancelCarbsEntryButton.safeTap()
    }
    
    // MARK: Verifications
    
    var simpleMealCalculatorExists: Bool {
        simpleMealCalculatorTitleText.safeExists
    }
    
    var carbEntryScreenExists: Bool {
        carbEntryTitleText.safeExists
    }
}
