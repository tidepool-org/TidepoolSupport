@Carbohydrates
Feature: Carbohydrates

@LOOP-1764
Scenario: View & Edit Carbohydrates
    Given app is launched
    When I skip all of onboarding
    Then closed loop displays
    When I add Carb Entry
        | CarbsAmmount | 40   |
        | FoodType     | Fast |
      And I deliver and authenticate bolus
      And I open Active Carbohydrates details
    Then the latest Carbohydrates record displays
        | CarbsAmount | 40   |
        | FoodType    | Fast |

@LOOP-2049
Scenario: Add Carb Entry - Editable field functionality
    Given app is launched
    When I skip all of onboarding
    Then closed loop displays
    When I set Carb Entry
      | FoodType | Fast |
    Then Carb Entry displays
      | AbsorbtionTime | 30 min |
    When I add Carb Entry
        | CarbsAmmount   | 40         |
        | ConsumeTime    | -5 minutes |
        | AbsorbtionTime | 30 minutes |
        | FoodType       | Other      |
      And I navigate back
    When I press decrease button "2" times to update Carb Entry time
    Then Consume Time displays updated value
    When I press increase button "1" time to update Carb Entry time
    Then Consume Time displays updated value
      And food collection contains food types
        | FAST   |
        | MEDIUM |
        | SLOW   |
        | OTHER  |
      And Carb Entry displays the most recently set data
    When I tap Continue on Carb Entry screen
      And I deliver and authenticate bolus
    Then temporary status bar displays current bolus progress

@LOOP-1897
Scenario: Enter Carbs and Bolus with Autopopulated bolus field
    Given app is launched
    When I skip all of onboarding
      And I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | MeasurementFrequency | fast |
    Then closed loop displays
    When I add Carb Entry
        | CarbsAmmount | 40   |
        | FoodType     | Fast |
      And I tap Save and Deliver button
      And I cancel bolus authentication
    Then Active Carbs value on Meal Bolus screen displays "0 g"
      And alert displays within 5 minutes
        | Title | Bolus Recommendation Updated |
    When I acknowledge alert
      And I deliver and authenticate bolus
    Then Active Carbohydrates displays value "40 g"
      And temporary status bar displays current bolus progress

@LOOP-2131
Scenario: Carb Entry Modifications - Editing, Backlogging and Future logging
    Given app is launched
    When I skip all of onboarding
      And I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | Model                | Constant   |
        | Constant             | 105        |
        | BackfillGlucose      | 23 hours   |
    Then closed loop displays
    When I set Carb Entry
        | CarbsAmmount | 25        |
        | FoodType     | Normal    |
        | ConsumeTime  | -13 hours |
    Then Consume Time was automatically adjusted to be 12 hours in the past
    When I set Carb Entry
        | ConsumeTime  | 0 hours |
    When I confirm edited Carb Entry and bolus recomendation
      And I add Carb Entry
        | CarbsAmmount | 25        |
        | FoodType     | Normal    |
      And I deliver and authenticate bolus
      And I open Active Carbohydrates details
    Then 2nd Carbohydrates record displays
        | CarbsAmount | 25                      |
        | FoodType    | Normal                  |
        | ConsumeTime | match the latest record |
    When I open details of 1st Carb record
    When I set Carb Entry
        | CarbsAmmount  | 66 |
    When I confirm edited Carb Entry and bolus recomendation
      And I set Carb Entry
        | CarbsAmmount | 30      |
        | FoodType     | Fast    |
      And I press increase button "5" times to update Carb Entry time
    Then Consume Time was automatically adjusted to be 1 hour in the future
    When I confirm edited Carb Entry and bolus recomendation
      And I open Active Carbohydrates details
    Then the latest Carbohydrates record displays
        | CarbsAmount | 30                      |
        | FoodType    | Fast                    |
        | ConsumeTime | match the latest record |
