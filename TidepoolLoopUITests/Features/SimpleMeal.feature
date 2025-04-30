@SimpleMeal
Feature: Simple Meal Calculator

Background:
    Given app is launched and intialy setup
     When I open settings
       And I turn off closed loop
       And I close settings screen
     Then open loop displays
     When I open Carb Entry
     Then simple meal calculator displays

@LOOP-2436
Scenario: Simple Meal Calculator - Recommended Bolus resets after Current Glucose and Carbohydrates values are removed
    When I set bolus screen values
      | CurrentGlucose | 300 |
    Then recommended bolus field is greater than value 0
      And bolus field is greater than value 0
    When I set bolus screen values
      | CurrentGlucose |  |
    Then recommended bolus field displays value –
      And bolus field displays value 0
    When I set bolus screen values
      | Carbohydrates | 20 |
    Then recommended bolus field is greater than value 0
      And bolus field is greater than value 0
    When I set bolus screen values
      | Carbohydrates |  |
    Then recommended bolus field displays value –
      And bolus field displays value 0

@LOOP-5199
Scenario: Simple Meal Calculator - Current Glucose Min and Max
    When I set bolus screen values
      | CurrentGlucose | 9  |
      | Bolus          | .2 |
    Then warning title displays "Glucose Entry Out of Range"
    When I set bolus screen values
      | CurrentGlucose | 10 |
      | Bolus          | .2 |
      And I deliver and authenticate bolus
    Then cgm pill displays value "10"
    When I open bolus setup
    Then simple bolus calculator displays
    When I set bolus screen values
      | CurrentGlucose | 601 |
      | Bolus          | .2  |
    Then warning title displays "Glucose Entry Out of Range"
    When I set bolus screen values
      | CurrentGlucose | 600 |
      | Bolus          | .2  |
      And I deliver and authenticate bolus
    Then cgm pill displays value "600"

@LOOP-5299
Scenario: Simple Meal Calculator -Happy Path flow (1 U, 5 g, 100 mg/dL)
    When I set bolus screen values
      | CurrentGlucose | 100 |
      | Carbohydrates  | 5   |
      | Bolus          | 1   |
      And I deliver and authenticate bolus
    Then cgm pill displays value "100"
  
@LOOP-5231
Scenario: Simple Meal Calculator- Bolus field resets to zero after Current Glucose value is changed
    When I set bolus screen values
      | CurrentGlucose | 200 |
      | Bolus          | 5   |
      | CurrentGlucose | 250 |
    Then bolus field displays value 0
    
@LOOP-5256
Scenario: Simple Meal Calculator - Recommended Bolus field updates with only Carbohydrate value
    When I set bolus screen values
      | Carbohydrates | 20 |
    Then recommended bolus field is greater than value 0
      And bolus field is greater than value 0
    When I set bolus screen values
      | Carbohydrates |  |
    Then recommended bolus field displays value –
      And bolus field displays value 0
    When I set bolus screen values
      | Carbohydrates | 40 |
    Then recommended bolus field is greater than value 0
      And bolus field is greater than value 0
    When I set bolus screen values
      | Carbohydrates |  |
    Then recommended bolus field displays value –
      And bolus field displays value 0
        
@LOOP-5288
Scenario: Simple Meal Calculator - Recommended Bolus updates accurately with Current Glucose and Carbohydrate value
    When I set bolus screen values
      | CurrentGlucose | 400 |
      | Carbohydrates  | 20  |
    Then recommended bolus field is greater than value 3
      And bolus field is greater than value 3
    When I set bolus screen values
      | CurrentGlucose |   |
    Then recommended bolus field is less than value 4
      and bolus field is less than value 4
