//
//  CGMManagerScreen.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 21.11.2024.
//

import XCTest

class CGMManagerScreen {
    
    // MARK: Elements
    
    private let cgmSimulatorTitle = app.navigationBars.staticTexts["CGM Simulator"]
    private let cgmSimulatorDoneButton = app.navigationBars["CGM Simulator"].buttons["Done"]
    
    // MARK: Actions
    
    var cgmSimulatorDisplayed: Bool { cgmSimulatorTitle.safeExists }

    func tapCgmSimulatorDoneButton() {
        cgmSimulatorDoneButton.safeTap()
    }
}
