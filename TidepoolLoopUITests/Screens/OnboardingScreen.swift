//
//  OnboardingScreen.swift
//  TidepoolLoopUITests
//
//  Created by Cameron Ingham on 2/13/24.
//

import XCTest

class OnboardingScreen {
    
    // MARK: Elements
    
    private let welcomeTitleText = app.staticTexts["Welcome to Tidepool Loop"]
    private let skipOnboardingAlert = app.alerts["Are you sure you want to skip the rest of onboarding (and use simulators)?"]
    private let allowNotificationsAlert = springBoard.alerts["“Tidepool Loop” Would Like to Send You Notifications"]
    private let allowCriticalAlertsAlert = springBoard.alerts["“Tidepool Loop” Would Like to Send You Critical Alerts"]
    private let skipSectionAlert = app.alerts["Are you sure you want to skip through this section?"]
    private let simulatorConfirmationButton = app.buttons["Yes"]
    private let alertAllowButton = springBoard.buttons["Allow"]
    private let turnOnAllHealthCategoriesText = app.tables.staticTexts["Turn On All"]
    private let healthDoneButton = app.navigationBars["Health Access"].buttons["Allow"]
    
    // MARK: Actions
    
    func welcomeTitleTextExists() -> Bool {
        welcomeTitleText.waitForExistence(timeout: TestSetup.basicWait)
    }
    
    func tapConfirmSkipOnboarding() {
        simulatorConfirmationButton.safeTap()
    }
    
    func tapForDurationWelcomTitle() {
        if welcomeTitleText.safeExists {
            welcomeTitleText.press(forDuration: 2.5)
        }
    }
    
    func allowNotifications() {
        if allowNotificationsAlert.waitForExistence(timeout: TestSetup.longWait) {
            alertAllowButton.safeTap()
        }
    }
    
    func allowCriticalAlerts() {
        if allowCriticalAlertsAlert.waitForExistence(timeout: TestSetup.longWait) {
            alertAllowButton.safeTap()
        }
    }
    
    func allowHealthKitAuthorization() {
        if turnOnAllHealthCategoriesText.waitForExistence(timeout: TestSetup.longWait) {
            turnOnAllHealthCategoriesText.tap()
            healthDoneButton.safeTap()
        }
    }
    
    func skipOnboarding() {
        for _ in 1...3 {
            tapForDurationWelcomTitle()
            if skipOnboardingAlertExists {
                tapConfirmSkipOnboarding()
                break
            }
        }
    }
    
    // MARK: Verifications
    
    var skipOnboardingAlertExists: Bool {
        skipOnboardingAlert.safeExists
    }
}
