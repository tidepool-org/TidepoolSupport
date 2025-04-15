//
//  CarbsEntrySteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 23.11.2024.
//

import CucumberSwift
import LoopUITestingKit
import XCTest

func carbsEntrySteps() {
    let carbsEntryScreen = CarbsEntryScreen(app: app)
    let activeCarbsScreen = ActiveCarbsScreen(app: app)
    let homeScreen = HomeScreen(app: app)
    let bolusScreen = BolusScreen(app: app)
    let navigationBar = NavigationBar(app: app)
    
    var lastCarbEntries: [String: String] = [:]
    
    // MARK: Actions
    
    When("I close carbs entry screen") { _, _ in
        carbsEntryScreen.tapCancelCarbsEntry()
    }
    
    When ("I set amount consumed value {string}") { matches, _ in
        carbsEntryScreen.setCarbsConsumedTextField(carbsAmount: try String  (matches.first(\.string)).replacing(",", with: "."))
        carbsEntryScreen.tapContinueButton()
    }
    
    When("I tap Continue on Carb Entry screen") { _, _ in
        carbsEntryScreen.tapContinueButton()
    }
    
    When(/^I (add|set) Carb Entry$/) { matches, step in
        let carbsSettingsMap = step.dataTable!.rows.map {
            row -> (key: String, value: String) in (key: row[0], value: row[1])
        }
        
        if homeScreen.carbsTabButtonisHittable { homeScreen.tapCarbEntry() }
        
        for carbsAttribute in carbsSettingsMap {
            switch carbsAttribute.key {
            case "CarbsAmmount":
                carbsEntryScreen.setCarbsConsumedTextField(carbsAmount: carbsAttribute.value)
            case "ConsumeTime":
                let timeAdjustmentInSeconds = getSecondsToAdjust(timeAdjustment: carbsAttribute.value)
                let adjustedTimeMap = addIntervalAndFormat(
                    seconds: timeAdjustmentInSeconds
                )
                
                switch timeAdjustmentInSeconds {
                case let x where x < (-12 * 3600): carbsEntryScreen.swipeDayPickerWheel(swipeDirection: .down)
                case let x where x > 3600: carbsEntryScreen.swipeDayPickerWheel(swipeDirection: .up)
                default:
                    carbsEntryScreen.setConsumedTime(
                        day: adjustedTimeMap.day,
                        hours: adjustedTimeMap.hour,
                        minutes: adjustedTimeMap.minute,
                        amPm: adjustedTimeMap.ampm
                    )
                }
            case "FoodType":
                carbsEntryScreen.setFoodType(foodType: carbsAttribute.value)
                if carbsEntryScreen.foodTypeTextFieldExists {
                    lastCarbEntries["FoodType"] = carbsEntryScreen.getFoodTypeValue
                }
            case "AbsorbtionTime":
                let attributeArray = carbsAttribute.value.components(separatedBy: ", ")
                var hourValue: String? = nil
                var minuteValue: String? = nil
                
                if let hourIndex = attributeArray.firstIndex(where: { $0.contains("hour") }) {
                    hourValue = attributeArray[hourIndex].components(separatedBy: " ")[0]
                }
                if let minuteIndex = attributeArray.firstIndex(where: { $0.contains("minute") }) {
                    minuteValue = attributeArray[minuteIndex].components(separatedBy: " ")[0]
                }
                
                carbsEntryScreen.setAbsorbtionTime(hours: hourValue, minutes: minuteValue)
            default: break
            }
            lastCarbEntries["ConsumeTime"] = carbsEntryScreen.getConsumedTimeText
            lastCarbEntries["AbsorbtionTime"] = carbsEntryScreen.getAbsorbtionTimeText
            lastCarbEntries["CarbsAmmount"] = carbsEntryScreen.getCarbsAmountValue
        }
        if matches.1 == "add" { carbsEntryScreen.tapContinueButton() }
    }
    
    When(/^I press (decrease|increase) button "(.*)" time(s|) to update Carb Entry time$/) { matches, _ in
        let tapCount = Int(matches.2) ?? 1
        let timeAdjustment = Double((matches.1 == "decrease" ? -1 : +1) * tapCount * 15 * 60)
        let adjustedTimeMap = addIntervalAndFormat(seconds: timeAdjustment)
        
        for _ in 1...tapCount {
            switch matches.1 {
            case "decrease": carbsEntryScreen.tapDecreaseConsumeTimeButton()
            case "increase": carbsEntryScreen.tapIncreaseConsumeTimeButton()
            default: break
            }
        }
        
        lastCarbEntries["ConsumeTime"] = carbsEntryScreen.getConsumedTimeText
    }
    
    // Active Carbs graph - details
    
    When(/^I open details of (\d+)(st|nd|rd|th) Carb record$/) { matches, _ in
        activeCarbsScreen.tapCarbEntryCell(cellIndex: Int(matches.1)! - 1)
    }
    
    When("I confirm edited Carb Entry and bolus recomendation") { _, _ in
        carbsEntryScreen.tapContinueButton()
        bolusScreen.tapBolusActionButton()
        if bolusScreen.passcodeEntryExists { bolusScreen.setPasscode() }
        if navigationBar.backButtonExists { navigationBar.tapBackButton() }
    }
    
    // MARK: Verifications
    
    Then("simple meal calculator displays") { _, _ in
        XCTAssert(carbsEntryScreen.simpleMealCalculatorExists)
    }
    
    Then("carb entry screen displays") { _, _ in
        XCTAssert(carbsEntryScreen.carbEntryScreenExists)
    }
    
    Then("meal bolus screen displays") { _, _ in
        XCTAssert(carbsEntryScreen.mealBolusScreenExists)
    }
    
    // Active Carbs graph - details
    Then(/^(the late|(\d+))(st|nd|rd|th) Carbohydrates record displays$/) { matches, step in
        var carbsEntryMap = step.dataTable!.rows.map {
            row -> (key: String, value: String) in (key: row[0], value: row[1])
        }
        let cellIndex = matches.1 == "the late" ? 1 : Int(matches.1) ?? 1
        let actualCarbValuesMap = activeCarbsScreen.getCarbEntryCellValues(cellIndex: cellIndex - 1)
        
        for carbEntry in carbsEntryMap {
            let actualValue = switch carbEntry.key {
            case "CarbsAmount": actualCarbValuesMap["CarbsAmountType"]?.components(separatedBy: " g: ")[0]
            case "FoodType":
                switch actualCarbValuesMap["CarbsAmountType"]?.components(separatedBy: " g: ")[1] {
                case "🍕": "Slow"
                case "🌮": "Normal"
                case "🍭": "Fast"
                default: ""
                }
            case "ConsumeTime":
                actualCarbValuesMap["ConsumeTime"]?.components(separatedBy: " ")[0]
            default: ""
            }
            
            if carbEntry.value == "match the latest record" {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US")
                dateFormatter.dateFormat = "h:mm a"
                let expectedTime = dateFormatter.date(from: lastCarbEntries["ConsumeTime"]!)
                let actualTime = dateFormatter.date(from: actualValue!.replacing(" ", with: " "))
                let timeDifference = expectedTime?.timeIntervalSince(actualTime!) ?? 1 // if nil set 1 second
                
                XCTAssertTrue(
                    abs(timeDifference) == 0,
                    "Expected time should be \(lastCarbEntries["ConsumeTime"]!) hours since now '\(Date.now)'. " +
                    "But actual is '\(actualValue!)'. Time difference is \(timeDifference)"
                )
            } else {
                XCTAssertEqual(carbEntry.value, actualValue)
            }
        }
    }
    
    Then("food collection contains food types") { _, step in
        var foodTypes: [String] = []
        var failureMsg: String = ""
        for row in step.dataTable!.rows {
            foodTypes.append(row[0])
        }
        
        carbsEntryScreen.foodTypeTextFieldExists ?
        carbsEntryScreen.tapFoodTypeTextField() : carbsEntryScreen.tapFoodType(foodType: "🍽️")
        
        let missingTypes = carbsEntryScreen.foodsCollectionContainsType(foodTypes: foodTypes)
        if let count = missingTypes?.count {
            failureMsg = count > 1 ? "types \(missingTypes!) don't" : "type \(missingTypes!) doesn't"
        }
        
        XCTAssertTrue(missingTypes == nil, "Food \(failureMsg) display.")
    }
    
    Then("Carb Entry displays") { _, step in
        let carbsEntryMap = step.dataTable!.rows.map {
            row -> (key: String, value: String) in (key: row[0], value: row[1])
        }
        
        for carbAttribute in carbsEntryMap {
            switch carbAttribute.key {
            case "CarbsAmmount": XCTAssertEqual(carbAttribute.value, carbsEntryScreen.getCarbsAmountValue)
            case "ConsumeTime": XCTAssertEqual(carbAttribute.value, carbsEntryScreen.getConsumedTimeText)
            case "FoodType": XCTAssertEqual(carbAttribute.value, carbsEntryScreen.getFoodTypeValue)
            case "AbsorbtionTime": XCTAssertEqual(carbAttribute.value, carbsEntryScreen.getAbsorbtionTimeText)
            default: XCTFail("Carb attribute '\(carbAttribute.key)' is not implemented in test framework yet.")
            }
        }
    }
    
    Then("Carb Entry displays the most recently set data") { _, _ in
        for carbAttribute in lastCarbEntries {
            switch carbAttribute.key {
            case "CarbsAmmount": XCTAssertEqual(carbAttribute.value, carbsEntryScreen.getCarbsAmountValue)
            case "ConsumeTime": XCTAssertEqual(carbAttribute.value, carbsEntryScreen.getConsumedTimeText)
            case "FoodType": XCTAssertEqual(carbAttribute.value, carbsEntryScreen.getFoodTypeValue)
            case "AbsorbtionTime": XCTAssertEqual(carbAttribute.value, carbsEntryScreen.getAbsorbtionTimeText)
            default: XCTFail("Carb attribute '\(carbAttribute.key)' is not implemented in test framework yet.")
            }
        }
    }
    
    Then(/^Consume Time displays updated value$/) { _, _ in
        XCTAssertEqual(lastCarbEntries["ConsumeTime"], carbsEntryScreen.getConsumedTimeText)
    }
    
    Then(/^Consume Time was automatically adjusted to be (12|1) hour(|s) in the (past|future)$/) { matches, _ in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US")
        let actualConsumeTime = carbsEntryScreen.getConsumeDateTime()
        
        let timeDifference = actualConsumeTime.timeIntervalSinceNow
        XCTAssert(
            abs(abs(timeDifference) - Double(matches.1)! * 3600) < 120,
            "Expected time should be \(matches.1) hours since now '\(Date.now)'. But actual is '\(actualConsumeTime)'. Time difference is \(timeDifference)"
        )
    }
    
    func getSecondsToAdjust(timeAdjustment: String) -> Double {
        var timeAdjustmentInSeconds = 0.0
        
        for component in timeAdjustment.components(separatedBy: ", ") {
            let trimmedComponent = component.trimmingCharacters(in: .whitespaces)
            
            if trimmedComponent.contains("hour") {
                let hourParts = trimmedComponent.components(separatedBy: " ")
                if let value = Int(hourParts[0]) {
                    timeAdjustmentInSeconds += Double(value * 3600)
                }
            } else if trimmedComponent.contains("minute") {
                let minuteParts = trimmedComponent.components(separatedBy: " ")
                if let value = Int(minuteParts[0]) {
                    timeAdjustmentInSeconds += Double(value * 60)
                }
            }
        }
        return timeAdjustmentInSeconds
    }
    
    func addIntervalAndFormat(seconds: TimeInterval) -> (day: String, hour: String, minute: String, ampm: String) {
        let currentDate = Date()
        let adjustedDate = currentDate.addingTimeInterval(seconds)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        
        dateFormatter.dateFormat = "MMM dd"
        let dayString = dateFormatter.string(from: adjustedDate)
        
        dateFormatter.dateFormat = "h"
        let hourString = dateFormatter.string(from: adjustedDate)
        
        dateFormatter.dateFormat = "mm"
        let minuteString = dateFormatter.string(from: adjustedDate)
        
        dateFormatter.dateFormat = "a"
        let ampmString = dateFormatter.string(from: adjustedDate)
        
        return (dayString, hourString, minuteString, ampmString)
    }
}
