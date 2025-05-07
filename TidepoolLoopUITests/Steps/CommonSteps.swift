//
//  CommonSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 18.11.2024.
//

import CucumberSwift
import LoopUITestingKit
import XCTest

func commonSteps() {
    let systemSettingsScreen = SystemSettingsScreen(app: app)
    let onboardingScreen = OnboardingScreen(app: app)
    
    // MARK: Preconditions
    
    Given("app is launched") { _, _ in
        app.launch()
    }
    
    Given("app is launched and intialy setup") { _, _ in
        app.launch()
        for _ in 1...3 {
            onboardingScreen.tapForDurationWelcomTitle()
            if onboardingScreen.skipOnboardingAlertExists {
                onboardingScreen.tapConfirmSkipOnboarding()
                break
            }
        }
        onboardingScreen.allowNotifications()
        onboardingScreen.allowCriticalAlerts()
        onboardingScreen.dontAllowHelthKitAuthorization()
    }
    
    // MARK: Actions
    
    When("I switch to tidepool loop app") { _, _ in
        app.activate()
    }
    
    When("I return to tidepool loop app") { _, _ in
        systemSettingsScreen.tapReturnToTidepoolButton(appName: appName)
    }
    
    When(/^I wait for (.*) (second[s]?|minute[s]?)$/) { matches, userInfo in
        let waitSeconds = matches.2.contains("second") ? Int(matches.1)! : Int(matches.1)! * 60
        let expectation = XCTestExpectation(description: "Wait for \(waitSeconds) seconds")
        print("Starting wait for: \(waitSeconds) seconds")
        
        var counter = 0
        var timer: Timer?
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            counter += 1
            print("Waited for: \(counter)/\(waitSeconds) seconds")
            if counter >= waitSeconds {
                timer?.invalidate()
                expectation.fulfill()
            }
        }
        userInfo.testCase!.executionTimeAllowance = TimeInterval(waitSeconds + 2)
        let result = XCTWaiter.wait(for: [expectation], timeout: TimeInterval(waitSeconds + 2))
        timer?.invalidate()
        print("Wait complete")
        XCTAssertEqual(result, .completed, "Wait did not complete successfully")
    }
}
