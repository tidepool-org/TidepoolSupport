//
//  OnboardingScreen.swift
//  TidepoolLoopUITests
//
//  Created by Cameron Ingham on 2/13/24.
//

import LoopUITestingKit
import XCTest

class OnboardingScreen: BaseScreen {
    
    // MARK: Elements

    var welcomeTitleText: XCUIElement {
        app.staticTexts["Welcome to Tidepool Loop"]
    }
    
    var simulatorAlert: XCUIElement {
        app.alerts["Are you sure you want to skip the rest of onboarding (and use simulators)?"]
    }
    
    var useSimulatorConfirmationButton: XCUIElement {
        app.buttons["Yes"]
    }
    
    var alertAllowButton:XCUIElement {
        springboardApp.buttons["Allow"]
    }
    
    var turnOnAllHealthCategoriesText: XCUIElement {
        app.tables.staticTexts["Turn On All"]
    }
    
    var healthDoneButton: XCUIElement {
        app.navigationBars["Health Access"].buttons["Allow"]
    }
    
    // MARK: Actions
    
    func skipAllOfOnboardingIfNeeded() {
        if welcomeTitleText.exists {
            skipAllOfOnboarding()
        }
    }
    
    func skipAllOfOnboarding() {
        skipOnboarding()
        allowSimulatorAlert()
        allowNotificationsAuthorization()
        allowCriticalAlertsAuthorization()
        allowHealthKitAuthorization()
    }

    private func skipOnboarding() {
        waitForExistence(welcomeTitleText)
        welcomeTitleText.press(forDuration: 2.5)
    }
    
    private func allowSimulatorAlert() {
//        sleep(UInt32(Common.TestSettings.elementTimeout))
        waitForExistence(simulatorAlert)
        if simulatorAlert.exists {
            useSimulatorConfirmationButton.tap()
        }
    }
    
    private func allowNotificationsAuthorization() {
        waitForExistence(alertAllowButton)
        alertAllowButton.tap()
    }
    
    private func allowCriticalAlertsAuthorization() {
        waitForExistence(alertAllowButton)
        alertAllowButton.tap()
    }
    
    private func allowHealthKitAuthorization() {
        waitForExistence(turnOnAllHealthCategoriesText)
        turnOnAllHealthCategoriesText.tap()
        healthDoneButton.tap()
    }
}
