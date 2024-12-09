//
//  Cucumber.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 28.11.2024.
//

import Foundation
import LoopUITestingKit
import XCTest
import CucumberSwift

let app = XCUIApplication(bundleIdentifier: ProcessInfo.processInfo.environment["bundleIdentifier"]!)
let systemSettings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
let springBoard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

extension Cucumber: StepImplementation {
    
    public var bundle: Bundle {
        class ThisBundle {}
        return Bundle(for: ThisBundle.self)
    }
    
    public func shouldRunWith(scenario: Scenario?, tags: [String]) -> Bool {
        true // select specific tests to be executed using tags e.g.: tags.contains("LOOP-1605")
    }
    
    public func setupSteps() {
        BeforeScenario { scenario in
            if !scenario.tags.isEmpty {
                Swift.print(scenario.tags.map { "@\($0)" }.joined(separator: " "))
            }
            Swift.print("Scenario: \(scenario.title)")
            app.uninstall()
        }
        
        carbsEntrySteps()
        bolusSteps()
        systemSettingsSteps()
        cGMManagerSteps()
        pumpManagerSteps()
        settingsSteps()
        homeSteps()
        notificationSteps()
        onboardingSteps()
        commonSteps()
    }
}
