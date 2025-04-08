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
    
    var lastCarbEntries: [String: String] = [:]
    var consumeTime: String = ""
    
    // MARK: Actions
    
    When("I close carbs entry screen") { _, _ in
        carbsEntryScreen.tapCancelCarbsEntry()
    }
    
    When("I tap Continue on Carb Entry screen") { _, _ in
        carbsEntryScreen.tapContinueButton()
    }
    
    When(/^I (add|set) Carb Entry$/) { matches, step in
        let carbsSettingsMap = step.dataTable!.rows.map {
            row -> (key: String, value: String) in (key: row[0], value: row[1])
        }
        
        if !carbsEntryScreen.carbEntryScreenExists { homeScreen.tapCarbEntry() }
        
        for carbsAttribute in carbsSettingsMap {
            switch carbsAttribute.key {
            case "CarbsAmmount":
                carbsEntryScreen.setCarbsConsumedTextField(carbsAmount: carbsAttribute.value)
                lastCarbEntries["CarbsAmmount"] = carbsEntryScreen.getCarbsAmountValue
            case "ConsumeTime":
                let adjustedTimeArray = getAdjustedTimeString(timeAdjustment: carbsAttribute.value)
                    .components(separatedBy: CharacterSet(charactersIn: ": "))
                
                carbsEntryScreen.setConsumedTime(
                    hours: adjustedTimeArray[0],
                    minutes: adjustedTimeArray[1],
                    amPm: adjustedTimeArray[2]
                )
                lastCarbEntries["ConsumeTime"] = carbsEntryScreen.getConsumedTimeText
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
                lastCarbEntries["AbsorbtionTime"] = carbsEntryScreen.getAbsorbtionTimeText
            default: break
            }
        }
        if matches.1 == "add" { carbsEntryScreen.tapContinueButton() }
    }
    
    When(/^I press (decrease|increase) button "(.*)" time(s|) to update Carb Entry time$/) { matches, _ in
        let tapCount = Int(matches.2) ?? 1
        let timeAdjustment = "\(matches.1 == "decrease" ? "-" : "+")\(tapCount * 15)"
        consumeTime = getAdjustedTimeString(timeAdjustment: timeAdjustment)
        lastCarbEntries["ConsumeTime"] = consumeTime
        
        for _ in 1...tapCount {
            switch matches.1 {
            case "decrease": carbsEntryScreen.tapDecreaseConsumeTimeButton()
            case "increase": carbsEntryScreen.tapIncreaseConsumeTimeButton()
            default: break
            }
        }
    }
    
    // MARK: Verifications
    
    Then("simple meal calculator displays") { _, _ in
        XCTAssert(carbsEntryScreen.simpleMealCalculatorExists)
    }
    
    Then("carb entry screen displays") { _, _ in
        XCTAssert(carbsEntryScreen.carbEntryScreenExists)
    }
    
    // Active Carbs graph - details
    Then("the latest Carbohydrates record displays") { _, step in
        let carbsEntryMap = step.dataTable!.rows.map {
            row -> (key: String, value: String) in (key: row[0], value: row[1])
        }
        let actualCarbValuesMap = activeCarbsScreen.getCarbEntryCellValues(cellIndex: 0)
        
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
            default: ""
            }
            
            XCTAssertEqual(carbEntry.value, actualValue)
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
        XCTAssertEqual(consumeTime, carbsEntryScreen.getConsumedTimeText)
    }
    
    func getAdjustedTimeString(timeAdjustment: String) -> String {
        let timeAdjustment = timeAdjustment.components(separatedBy: ", ")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let timeAdjustmentInSeconds = switch timeAdjustment.count {
        case 1: Double(timeAdjustment[0].components(separatedBy: " ")[0])! * 60
        case 2: Double(timeAdjustment[0].components(separatedBy: " ")[0])! * 3600 +
            Double(timeAdjustment[1].components(separatedBy: " ")[0])! * 60
        default: 0.0
        }
        let adjustedTime = dateFormatter
            .date(from: carbsEntryScreen.getConsumedTimeText)?
            .addingTimeInterval(timeAdjustmentInSeconds)

        return dateFormatter.string(for: adjustedTime) ?? ""
    }
}
