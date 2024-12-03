//
//  CGMManagerSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 21.11.2024.
//

import XCTest
import CucumberSwift

func cGMManagerSteps() {
    let cgmManagerScreen = CGMManagerScreen()
    
    // MARK: Actions
    
    When("I close cgm manager") { _, _ in
        cgmManagerScreen.tapCgmSimulatorDoneButton()
    }
    
    // MARK: Verifications
    
    Then("cgm manager displays") { _, _ in
        XCTAssert(cgmManagerScreen.cgmSimulatorDisplayed)
    }
}
