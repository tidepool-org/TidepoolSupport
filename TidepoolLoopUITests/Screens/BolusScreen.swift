//
//  BolusScreen.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 23.11.2024.
//

import XCTest

class BolusScreen {
    
    // MARK: Elements

    private let bolusTitleText = app.navigationBars.staticTexts["Bolus"]
    private let bolusEntryTextField = app.textFields["dismissibleKeyboardTextField"]
    private let bolusCancelButton = app.navigationBars.buttons["Cancel"]
    private let simpleBolusCalculatorTitle = app.navigationBars.staticTexts["Simple Bolus Calculator"]
    private let deliverBolusButton = app.buttons["Deliver"]
    private let passcodeEntry = springBoard.secureTextFields["Passcode field"]
    private let keyboardDoneButton = app.toolbars.firstMatch.buttons["Done"].firstMatch
    
    // MARK: Actions
    
    func tapCancelBolusButton() {
        bolusCancelButton.safeTap()
    }
    
    func tapBolusEntryTextField() {
        bolusEntryTextField.safeTap()
    }
    
    func tapDeliverBolusButton() {
        deliverBolusButton.safeForceTap()
    }
    
    func clearBolusEntryTextField() {
        let currentTextLength = bolusEntryTextField.getValueSafe().count
        
        bolusEntryTextField
            .typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentTextLength))
    }
    
    func setPasscode() {
        passcodeEntry.safeTap()
        passcodeEntry.typeText("1\n")
    }
    
    func setBolusEntryTextField(value: Float) {
        bolusEntryTextField.typeText(String(value))
    }
    
    func tapKeyboardDoneButton() {
        keyboardDoneButton.safeTap()
    }
    
    // MARK: Verifications
    
    var bolusTitleExists: Bool {
        bolusTitleText.safeExists
    }
    
    var simpleBolusCalculatorTitleExists: Bool {
        simpleBolusCalculatorTitle.safeExists
    }
}
