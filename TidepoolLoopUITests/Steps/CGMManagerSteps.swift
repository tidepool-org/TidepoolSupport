//
//  CGMManagerSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 21.11.2024.
//

import XCTest

class CGMManagerSteps {
    let cgmManagerScreen = CGMManagerScreen()
    
    // MARK: Actions
    
    func when_i_close_cgm_manager() {
        cgmManagerScreen.tapCgmSimulatorDoneButton()
    }
    
    // MARK: Verifications
    
    func then_cgm_manager_displays() {
        XCTAssert(cgmManagerScreen.cgmSimulatorDisplayed)
    }
}
