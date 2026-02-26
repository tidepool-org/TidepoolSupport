//
//  HomeSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 19.11.2024.
//

import CucumberSwift
import CucumberSwiftExpressions
import LoopUITestingKit
import XCTest

func homeSteps() {
    let homeScreen = HomeScreen(app: app)
    let bolusScreen = BolusScreen(app: app)
    
    var xAxisLabelCount: [Int] = []
    var bolusValue: String = ""
    var cgmValue: String = ""
    
    // MARK: Actions
    
    When("I open settings") { _, _ in
        homeScreen.tapSettingsButton()
    }
    
    When("I open Presets") { _, _ in
        homeScreen.tapPresetsTabButton()
    }
    
    When("I open CGM manager") { _, _ in
        homeScreen.tapHudGlucosePill()
    }
    
    When(/^I tap (closed|open) loop icon$/) { matches, _ in
        matches.1 == "closed" ? homeScreen.tapLoopStatusClosed() : homeScreen.tapLoopStatusOpen()
    }
    
    When("I dismiss closed loop status alert") { _, _ in
        homeScreen.tapLoopStatusAlertDismissButton()
    }
    
    When("I open bolus setup") { _, _ in
        homeScreen.tapBolusEntry()
    }
    
    When("I open Carb Entry") { _, _ in
        homeScreen.tapCarbEntry()
    }
    
    When("I open Active Carbohydrates details") { _, _ in
        homeScreen.tapNavigateToActiveCarbsDetails()
    }
    
    When("I open pump manager") { _, _ in
        homeScreen.tapPumpPill()
    }
    
    When(/^I tap Preset banner$/) { matches, _ in
        homeScreen.tapPresetBannerText()
    }
    
    When(/^I open Insulin Delivery$/) { _, _ in
        homeScreen.tapNavigateToActiveInsulinDetailsText()
	}

    When("I tap Tap to Stop") { _, _ in
        homeScreen.tapTapToStop()
    }
    
    When("I tap Tap to Resume") { _, _ in
        homeScreen.tapInsulinTapToResumeCell()
    }
    When("I tap Preset banner") { _, _ in
        homeScreen.tapPresetBannerText()
    }
    When("I store the X axis period") { _, _ in
        xAxisLabelCount =
            [homeScreen.getGlucoseXAxisCount, homeScreen.getActiveInsulinXAxisCount, homeScreen.getActiveCarbsXAxisCount]
    }
    
    When("I store Bolus value") { _, _ in
        bolusValue = bolusScreen.getBolusTextFieldValue
    }
    
    When("I wait for the new CGM measurement") { _, _ in
        let currentValue = homeScreen.getHudGlucosePillValue()[0].components(separatedBy: " ")[0]
        var newCgmValue: String
        
        for _ in 1...300 {
            sleep(1)
            newCgmValue = homeScreen.getHudGlucosePillValue()[0].components(separatedBy: " ")[0]
            if currentValue != newCgmValue {
                cgmValue = newCgmValue
                break
            }
        }
    }
    
    // MARK: Verifications
    
    Then(/^glucose chart (allows|doesn't allow) navigation to detailed view$/) { matches, _ in
        XCTAssertTrue((matches.1 == "doesn't allow") == homeScreen.navigationToGlucoseDetailsIsDisabled)
    }
    
    Then(/^(open|closed) loop (displays|does not display)$/) { matches, _ in
        let doesDisplay = matches.2 == "displays"
        let errMsg = doesDisplay ? "does not display" : "displays"
        
        if matches.1 == "closed" {
            XCTAssertTrue(
                doesDisplay ? homeScreen.hudStatusClosedLoopExists : homeScreen.hudStatusClosedLoopNotExists,
                "Closed loop \(errMsg)."
            )
        } else {
            sleep(3)
            XCTAssert(
                doesDisplay ? homeScreen.hudStatusOpenLoopExists : homeScreen.hudStatusOpenLoopNotExists,
                "Open loop \(errMsg)."
            )
        }
    }
    
    Then(/^closed loop (on|off) alert displays$/) { matches, _ in
        XCTAssert(matches.1 == "on" ? homeScreen.closedLoopOnAlertTitleExists : homeScreen.closedLoopOffAlertTitleExists)
    }
    
    Then(/^pump pill displays value \"(.*?)\"$/) { matches, _ in
        XCTAssert(homeScreen.getPumpPillValue().contains(matches.1))
    }
    
    Then(/^cgm pill (doesn't display|displays) (value|trend|alert) \"(.*?)\"$/) { matches, _ in
        let expectedValue = matches.3 == "stored value" ? cgmValue : String(matches.3)
        let actualValue = switch matches.2 {
        case "value": homeScreen.getHudGlucosePillValue()[0].components(separatedBy: " ")[0]
        case "trend": homeScreen.getHudGlucosePillValue()[1]
        case "alert": homeScreen.getHudGlucosePillValue()[0]
        default: ""
        }
        
        XCTAssertEqual(
            expectedValue == actualValue,
            matches.1 == "displays",
            "Comparison of expected \(matches.2) '\(expectedValue)' and actual value '\(actualValue)' should be" +
            " \(matches.1 == "displays") but was \(!(matches.1 == "displays"))"
        )
    }
    
    Then(/^temporary status bar displays "?(current bolus progress|No Recent Glucose)"?(| after (.*?) (second[s]?|minute[s]?))$/) { matches, userInfo in
        switch matches.1 {
        case "current bolus progress":
            XCTAssertTrue(homeScreen.bolusProgressTextExists, "Temporary status bar with bolus progress is not displayed.")
            XCTAssertTrue(homeScreen.tapToStopTextExists, "'Tap to Stop' option is not available on temporary status bar.")
        case "No Recent Glucose":
            let waitSeconds = matches.4!.contains("second") ? Int(matches.3!)! : Int(matches.3!)! * 60
            let relativeBufferTime = Int(waitSeconds/3 + 5) + waitSeconds
            XCTAssertTrue(homeScreen.noRecentGlucoseTextExists(passAfter: waitSeconds, failAfter: relativeBufferTime, testInfo: userInfo.testCase!), "No Recent Glucose text doesn't display.")
        default:
            XCTFail("\(matches.1) is either not a valid option or not implemented yet.")
        }
    }
    
    Then(/^(.*) Preset banner (displays|does not display)$/) { matches, _ in
        let expectedName = String(matches.1)
        if matches.2 == "displays" {
            XCTAssertTrue(homeScreen.presetBannerTextExists, "Preset banner text does not display")
            let presetBannerText = homeScreen.getPresetBannerText
            let isNameInBannerText = presetBannerText.contains(expectedName)
            XCTAssertTrue(isNameInBannerText,
                           "Expected banner '\(expectedName)' was not found within '\(presetBannerText)'")
        }
        else if homeScreen.presetBannerTextNoExist {
            XCTAssertTrue(true)
        }
        else {
            let presetBannerText = homeScreen.getPresetBannerText
            let isNameInBannerText = presetBannerText.contains(expectedName)
            XCTAssertFalse(isNameInBannerText,
                              "Current preset banner incorrectly matches forbidden name '\(expectedName)'")
        }
    }
    Then(/^Preset banner duration displays "?(.+?)"?$/) { matches, _ in
        let input = matches.1.trimmingCharacters(in: .whitespacesAndNewlines)
        let bannerDuration = homeScreen.getPresetActiveOnText

        //
        // 1️⃣ CASE: Literal string "on until carbs added"
        //
        if input == "on until carbs added" {
            XCTAssertTrue(
                bannerDuration.contains("on until carbs added"),
                "Expected banner to display 'on until carbs added', but saw: \(bannerDuration)"
            )
            return
        }

        //
        // 2️⃣ CASE: Relative format (“+3 hours”, “+1 minute”)
        //
        if input.first == "+" {
            let parts = input.dropFirst().split(separator: " ")
            guard parts.count == 2,
                  let amount = Int(parts[0]) else {
                XCTFail("Invalid relative duration format: \(input)")
                return
            }

            let unit = parts[1]
            let now = Date()
            var target = now

            if unit.starts(with: "hour") {
                target = Calendar.current.date(byAdding: .hour, value: amount, to: now)!
            } else if unit.starts(with: "minute") {
                target = Calendar.current.date(byAdding: .minute, value: amount, to: now)!
            } else {
                XCTFail("Invalid unit in: \(input)")
            }

            // Format expected time
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.dateFormat = "h:mm a"

            let expectedTime = fmt.string(from: target)

            let acceptableTimes = [
                fmt.string(from: Calendar.current.date(byAdding: .minute, value: -1, to: target)!),
                expectedTime
            ]
            let clean = { (s: String) in
                s.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
            }
            let cleanedBannerDuration = clean(bannerDuration)
            let cleanedAcceptableTimes = acceptableTimes.map(clean)
            let matches = cleanedAcceptableTimes.contains { cleanedBannerDuration.contains($0) }
            XCTAssertTrue(
                matches,
                """
                Expected time within ±1 min of \(expectedTime).
                Acceptable: \(cleanedAcceptableTimes)
                Actual banner time: \(cleanedBannerDuration)
                """
            )
            return
        }

        //
        // 3️⃣ CASE: Absolute time, e.g. “11:09 AM”
        //
        let absoluteTimeRegex = #"^\d{1,2}:\d{2}\s?(AM|PM)$"#
        if input.range(of: absoluteTimeRegex, options: .regularExpression) != nil {

            // Normalize whitespace to avoid iOS inserting U+202F
            let normalizedInput = input.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
            let normalizedBanner = bannerDuration.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)

            XCTAssertTrue(
                normalizedBanner.contains(normalizedInput),
                "Expected banner to contain time '\(input)', but saw: \(bannerDuration)"
            )
            return
        }

        XCTFail("Unrecognized banner duration format: \(input)")
    }
    
    Then(/^Active Carbohydrates displays value "(.*)" g$/) { matches, _ in        
        XCTAssertEqual(String(matches.1), homeScreen.getActiveCarbsValue)
    }
    
    Then(/^status bar (does|doesn't) display "?(.*?)"?$/) { matches, _ in
        switch String(matches.output.2) {
        case "Insulin Suspended":
            if String(matches.1) == "does" {
                XCTAssert(homeScreen.insulinSuspendedTextExists && homeScreen.insulinTapToResumeTextExists)
            } else {
                XCTAssert(homeScreen.insulinSuspendedTextNotExists)
            }
        case "Bolus Canceled":
            XCTAssert(matches.1=="does" ? homeScreen.bolusCanceledTextExists : homeScreen.bolusCanceledTextNotExists)
        case "Bolus Progress":
            XCTAssertTrue(homeScreen.bolusProgressTextExists, "Temporary status bar with bolus progress is not displayed.")
            XCTAssertTrue(homeScreen.tapToStopTextExists, "'Tap to Stop' option is not available on temporary status bar.")
        default:XCTFail("Only 'Insulin Suspended' and 'Bolus Canceled' parameters are supported in test framework.")
        }
    }
        
    Then(/^status bar \"(.*?)\" dismisses$/) { matches, _ in
        switch matches.1 {
        case "Insulin Suspended":
            XCTAssertTrue(homeScreen.insulinSuspendedTextNotExists)
        case "Bolus Canceled":
            XCTAssertTrue(homeScreen.bolusCanceledTextNotExists)
        case "Bolus Progress":
            XCTAssertTrue(homeScreen.bolusProgressTextNotExists)
        default: XCTFail("Only 'Insulin Suspended' and 'Bolus Canceled' parameters are supported in test framework.")
        }
    }
    
    Then(/^graphs displays longer time period in landscape view$/) { _, _ in
        let landScapeXAxisLabelCount =
            [homeScreen.getGlucoseXAxisCount, homeScreen.getActiveInsulinXAxisCount, homeScreen.getActiveCarbsXAxisCount]
        
        for (index, xAxis) in xAxisLabelCount.enumerated() {
            XCTAssertTrue(
                xAxis < landScapeXAxisLabelCount[index],
                "Number of portrait X axis labels is '\(xAxis)' but landscape view displays smaller time period " +
                "marked by '\(landScapeXAxisLabelCount[index])' X axis labels."
            )
        }
    }
    
    Then(/^Last Bolus value displays "?(.*?)"?$/) { matches, _ in
        print(app.debugDescription)
        let lastBolusValue = homeScreen.getActiveInsulinLastBolusValue
        let expectedValue = matches.1 == "stored value" ? bolusValue : String(matches.1)
        XCTAssertTrue(
            lastBolusValue.contains(expectedValue),
            "Value '\(lastBolusValue)' does not contains bolus value '\(expectedValue)'."
        )
    }
}
