//
//  TidepoolLoopUITests.swift
//  TidepoolLoopUITests
//
//  Created by Cameron Ingham on 2/6/24.
//  Copyright © 2024 LoopKit Authors. All rights reserved.
//

import LoopUITestingKit
import XCTest

@MainActor
final class TidepoolLoopUITests: XCTestCase {
    let app = XCUIApplication(bundleIdentifier: Common.TestSettings.bundleIdentifier)
    
    var baseScreen: BaseScreen!
    var onboardingScreen: OnboardingScreen!
    var homeScreen: HomeScreen!
    var settingsScreen: SettingsScreen!
    var systemSettingsScreen: SystemSettingsScreen!
    var pumpSimulatorScreen: PumpSimulatorScreen!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        baseScreen = BaseScreen(app: app)
        onboardingScreen = OnboardingScreen(app: app)
        homeScreen = HomeScreen(app: app)
        settingsScreen = SettingsScreen(app: app)
        systemSettingsScreen = SystemSettingsScreen(app: app)
        pumpSimulatorScreen = PumpSimulatorScreen(app: app)
    }

    func testSkippingOnboardingLeadsToHomepageWithSimulators() {
        onboardingScreen.skipAllOfOnboarding()
        sleep(3) // sleep for a little to allow for HUD to update
        waitForExistence(homeScreen.hudStatusClosedLoop)
        homeScreen.openSettings()
        settingsScreen.openPumpManager()
        waitForExistence(settingsScreen.pumpSimulatorTitle)
        settingsScreen.closePumpSimulator()
        settingsScreen.openCGMManager()
        waitForExistence(settingsScreen.cgmSimulatorTitle)
        settingsScreen.closeCGMSimulator()
        settingsScreen.closeSettingsScreen()
        waitForExistence(homeScreen.hudStatusClosedLoop)
    }
}
