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

var appName: String = ""

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
            let bundleIdentifier = ProcessInfo.processInfo.environment["bundleIdentifier"]!
            
            if !scenario.tags.isEmpty {
                Swift.print(scenario.tags.map { "@\($0)" }.joined(separator: " "))
            }
            Swift.print("Scenario: \(scenario.title)")
            appName = switch bundleIdentifier {
                case "org.tidepool.Loop": "Tidepool Loop"
                case "org.tidepool.coastal.Loop": "Tidepool Loop Coastal"
                case "org.tidepool.diy.Loop": "TidepoolLoopDIY"
                default: "Bundle Identifier \(bundleIdentifier) has no associated app name."
            }
            if appName.contains("no associated app name") { XCTFail(appName) }
            app.uninstall(appName: appName)
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
