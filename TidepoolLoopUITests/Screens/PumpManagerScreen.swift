//
//  PumpSimulatorScreen.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 19.11.2024.
//

import XCTest

public final class PumpManagerScreen {

    // MARK: Elements
    
    private let suspendInsulinButton = app.descendants(matching: .any).buttons["Suspend Insulin Delivery"]
    private let resumeInsulinButton = app.descendants(matching: .any).buttons["Tap to Resume Insulin Delivery"]
    private let doneButton = app.navigationBars["Pump Simulator"].buttons["Done"]
    private let pumpManagerProgressImage = app.images["mockPumpManagerProgressView"]
    private let reservoirRemainingButton =
        app.descendants(matching: .any).matching(identifier: "mockPumpSettingsReservoirRemaining").firstMatch
    private let reservoirRemainingTextField = app.descendants(matching: .any).textFields.firstMatch
    private let pumpSettingsBackButton = app.navigationBars.buttons["Back"]
    private let reservoirRemainingBackButton = app.navigationBars.firstMatch.buttons["Back"]
    private let detectOcclusionButton = app.staticTexts["Detect Occlusion"]
    private let resolveOcclusionButton = app.staticTexts["Resolve Occlusion"]
    private let causePumpErrorButton = app.staticTexts["Cause Pump Error"]
    private let resolvePumpErrorButton = app.staticTexts["Resolve Pump Error"]
    private let pumpSimulatorTitle = app.navigationBars.staticTexts["Pump Simulator"]
    
    // MARK: Actions
    
    var pumpSimulatorDisplayed: Bool { pumpSimulatorTitle.safeExists }
    
    func tapSuspendInsulinButton() {
        suspendInsulinButton.safeTap()
    }
    
    func tapResumeInsulinButton() {
        resumeInsulinButton.safeTap()
    }
    
    func tapPumpSimulatorDoneButton() {
        doneButton.safeTap()
    }
    
    func tapPumpManagerProgressImage() {
        pumpManagerProgressImage.press(forDuration: 10)
    }
    
    func tapPumpSettingsBackButton() {
        pumpSettingsBackButton.safeTap()
    }
    
    func tapReservoirRemainingRow() {
        reservoirRemainingButton.safeTap()
    }
    
    func tapReservoirRemainingTextField() {
        reservoirRemainingTextField.safeTap()
    }
    
    func clearReservoirRemainingTextField() {
        let currentTextLength = reservoirRemainingTextField.getValueSafe().count
        
        reservoirRemainingTextField
            .typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentTextLength))
    }
    
    func closeReservoirRemainingScreen() {
        reservoirRemainingBackButton.safeTap()
    }
    
    func setReservoirRemainingText(value: Float) {
        reservoirRemainingTextField.typeText(String(value))
    }
    
    func tapDetectOcclusionButton() {
        detectOcclusionButton.safeTap()
    }
    
    func tapResolveOcclusionButton() {
        resolveOcclusionButton.safeTap()
    }
    
    func tapCausePumpErrorButton() {
        causePumpErrorButton.safeTap()
    }
    
    func tapResolvePumpErrorButton() {
        resolvePumpErrorButton.safeTap()
    }
    
    // MARK: Verifications
    
    var resumeInsulinButtonExists: Bool {
        resumeInsulinButton.safeExists
    }
    
    var suspendInsulinButtonExists: Bool {
        suspendInsulinButton.safeExists
    }
}
