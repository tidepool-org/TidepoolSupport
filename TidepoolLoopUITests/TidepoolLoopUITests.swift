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
        app = XCUIApplication(bundleIdentifier: Bundle.main.bundleIdentifier!)
        app.launch()
        baseScreen = BaseScreen(app: app, appName: "Tidepool Loop")
        onboardingScreen = OnboardingScreen(app: app, appName: "Tidepool Loop")
        homeScreen = HomeScreen(app: app, appName: "Tidepool Loop")
        settingsScreen = SettingsScreen(app: app, appName: "Tidepool Loop")
        systemSettingsScreen = SystemSettingsScreen(app: app, appName: "Tidepool Loop")
        pumpSimulatorScreen = PumpSimulatorScreen(app: app, appName: "Tidepool Loop")
        common = Common(appName: "Tidepool Loop")
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
