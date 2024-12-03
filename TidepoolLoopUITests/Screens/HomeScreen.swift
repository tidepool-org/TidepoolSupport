//
//  HomeScreen.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 19.11.2024.
//

import XCTest

public class HomeScreen {
    
    // MARK: Elements
    
    // Navigation bar
    private let settingsTabButton = app.buttons["statusTableViewControllerSettingsButton"]
    private let carbsTabButton = app.buttons["statusTableViewControllerCarbsButton"]
    private let bolusTabButton = app.buttons["statusTableViewControllerBolusButton"]
    private let preMealTabButton = app.buttons["statusTableViewPreMealButton"]
    
    private let hudStatusClosedLoop =
        app.descendants(matching: .any).matching(identifier: "loopCompletionHUDLoopStatusClosed").firstMatch
    private let hudPumpPill = app.descendants(matching: .any).matching(identifier: "pumpHUDView").firstMatch
    private let closedLoopOnAlertTitle = app.staticTexts["Closed Loop ON"]
    private let hudStatusOpenLoop =
        app.descendants(matching: .any).matching(identifier: "loopCompletionHUDLoopStatusOpen").firstMatch
    private let closedLoopOffAlertTitle = app.staticTexts["Closed Loop OFF"]
    private let safetyNotificationsAlertTitle = app.alerts["\n\nWarning! Safety notifications are turned OFF"]
    private let safetyNotificationsAlertCloseButton = app.alerts.firstMatch.buttons["Close"]
    private let alertDismissButton = app.buttons["Dismiss"]
    private let preMealDialogCancelButton = app.buttons["Cancel"]
    private let springboardKeyboardDoneButton = springBoard.keyboards.buttons["done"]
    
    
    // MARK: Actions

    func tapBolusEntry() {
        bolusTabButton.safeTap()
    }
    
    var hudStatusClosedLoopExists: Bool {
        hudStatusClosedLoop.waitForExistence(timeout: 120)
    }
    
    func tapSettingsButton() {
        settingsTabButton.safeTap()
    }
    
    func tapSafetyNotificationAlertCloseButton() {
        safetyNotificationsAlertCloseButton.safeTap()
    }
    
    func tapLoopStatusOpen() {
        hudStatusOpenLoop.safeTap()
    }
    
    func tapLoopStatusClosed() {
        hudStatusClosedLoop.safeTap()
    }
    
    func tapLoopStatusAlertDismissButton() {
        alertDismissButton.safeTap()
    }
    
    func tapPreMealButton() {
        preMealTabButton.safeTap()
    }
    
    func tapPreMealDialogCancelButton() {
        preMealDialogCancelButton.safeTap()
    }
    
    func tapCarbEntry() {
        carbsTabButton.safeTap()
    }
    
    func tapPumpPill() {
        hudPumpPill.safeTap()
    }
    
    func getPumpPillValue() -> String {
        hudPumpPill.getValueSafe()
    }
    
    // MARK: Verifications
    
    var hudStatusOpenLoopExists: Bool {
        hudStatusOpenLoop.safeExists
    }
    
    var preMealButtonEnabled: Bool {
        preMealTabButton.safeIsEnabled()
    }
    
    var closedLoopOffAlertTitleExists: Bool {
        closedLoopOffAlertTitle.safeExists
    }
    
    var closedLoopOnAlertTitleExists: Bool {
        closedLoopOnAlertTitle.safeExists
    }
}
