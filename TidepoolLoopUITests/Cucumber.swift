//
//  Cucumber.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 28.11.2024.
//

import Foundation
import XCTest
import CucumberSwift

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
