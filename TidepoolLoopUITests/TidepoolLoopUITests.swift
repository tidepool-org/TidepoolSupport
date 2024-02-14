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
        app = XCUIApplication(bundleIdentifier: "org.tidepool.Loop")
        app.launch()
        baseScreen = BaseScreen(app: app)
        onboardingScreen = OnboardingScreen(app: app)
        homeScreen = HomeScreen(app: app)
        settingsScreen = SettingsScreen(app: app)
        systemSettingsScreen = SystemSettingsScreen()
        pumpSimulatorScreen = PumpSimulatorScreen(app: app)
        common = Common(appName: "Tidepool Loop")
    }

    func testSkippingOnboardingLeadsToHomepageWithSimulators() {
        baseScreen.deleteApp(appName: "Tidepool Loop")
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
