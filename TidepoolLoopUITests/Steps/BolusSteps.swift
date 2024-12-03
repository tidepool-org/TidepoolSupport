//
//  BolusSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 23.11.2024.
//

import XCTest

class BolusSteps {
    let bolusScreen = BolusScreen()
    
    // MARK: Actions
    
    func when_i_close_bolus_screen() {
        bolusScreen.tapCancelBolusButton()
    }
    
    func when_i_set_bolus_value(bolusValue: String) {
        bolusScreen.tapBolusEntryTextField()
        bolusScreen.clearBolusEntryTextField()
        bolusScreen.setBolusEntryTextField(value: bolusValue)
        bolusScreen.tapKeyboardDoneButton()
    }
    
    func when_i_deliver_and_authenticate_bolus() {
        bolusScreen.tapDeliverBolusButton()
        bolusScreen.setPasscode()
    }
    
    // MARK: Verifications
    
    func then_simple_bolus_calculator_displays() {
        XCTAssert(bolusScreen.simpleBolusCalculatorTitleExists)
    }
    
    func then_bolus_screen_displays() {
        XCTAssert(bolusScreen.bolusTitleExists)
    }
}
