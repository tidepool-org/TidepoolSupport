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
    var app: XCUIApplication!
    var baseScreen: BaseScreen!
    var onboardingScreen: OnboardingScreen!
    var homeScreen: HomeScreen!
    var settingsScreen: SettingsScreen!
    var systemSettingsScreen: SystemSettingsScreen!
    var pumpSimulatorScreen: PumpSimulatorScreen!
    var common: Common!

    override func setUpWithError() throws {
        continueAfterFailure = false
        let common = Common()
        app = XCUIApplication(bundleIdentifier: common.bundleIdentifier)
        app.launch()
        baseScreen = BaseScreen(app: app)
        onboardingScreen = OnboardingScreen(app: app)
        homeScreen = HomeScreen(app: app)
        settingsScreen = SettingsScreen(app: app)
        systemSettingsScreen = SystemSettingsScreen(app: app)
        pumpSimulatorScreen = PumpSimulatorScreen(app: app)
        self.common = common
    }

    func testSkippingOnboardingLeadsToHomepageWithSimulators() {
        baseScreen.deleteApp()
        app.launch()
        onboardingScreen.skipAllOfOnboarding()
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
