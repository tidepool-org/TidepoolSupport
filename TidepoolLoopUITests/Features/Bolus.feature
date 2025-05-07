@Bolus
Feature: Bolus

@LOOP-2045
Scenario: Bolus - Happy Path flow (Variation: 1 U)
    Given app is launched and intialy setup
    When I open bolus setup
    Then bolus screen displays
    When I set bolus screen values
      | Bolus  |  1  |
      And I deliver and authenticate bolus
    Then temporary status bar displays current bolus progress
    
@LOOP-1777
Scenario: Bolus - Recommended  Bolus updates after new CGM data is received
    Given app is launched and intialy setup
    Then closed loop displays
    When I open CGM manager
      And I open CGM Simulator settings
      And I setup CGM Simulator
        | Model                | Constant   |
        | Constant             | 405        |
        | BackfillGlucose      | 15 minutes |
      And I open bolus setup
    Then bolus screen displays
    When I set bolus screen values
      | Bolus  | 9 |
    Then alert displays within 5 minutes
      | Title | Bolus Recommendation Updated |
      And bolus field displays value 0
    When I acknowledge alert
      And I set bolus screen values
        | Bolus  | .5  |
      And I deliver and authenticate bolus
    Then temporary status bar displays current bolus progress
    
@LOOP-5276
Scenario: Bolus - No Recent Glucose Data warning displays
    Given app is launched and intialy setup
    Then closed loop displays
    When I open CGM manager
      And I open CGM Simulator settings
      And I setup CGM Simulator
        | Model            | SignalLoss   |
      And I close cgm manager
    Then closed loop displays
    When I wait for 15 minutes
    Then temporary status bar displays "No Recent Glucose"
    When I open bolus setup
    Then warning title displays "No Recent Glucose Data"
    When I tap "Enter Fingerstick Glucose"
    Then bolus screen displays
    When I set bolus screen values
      | Bolus  | .3 |
      And I deliver and authenticate bolus
    Then temporary status bar displays current bolus progress
    When I wait for 30 seconds
    Then temporary status bar displays "No Recent Glucose"
    When I open bolus setup
    Then warning title displays "No Recent Glucose Data"
    When I tap "Enter Fingerstick Glucose"
    Then bolus screen displays
    When I set bolus screen values
      | FingerstickGlucose | 100 |
      | Bolus              | .2  |
      And I deliver and authenticate bolus
    Then temporary status bar displays current bolus progress

@LOOP-1818
Scenario: Bolus -  Recommended Bolus value updates when fresh CGM data is received while on screen
    Given app is launched and intialy setup
    Then closed loop displays
    When I open CGM manager
      And I open CGM Simulator settings
      And I setup CGM Simulator
        | Model   | SignalLoss   |
      And I close cgm manager
    Then closed loop displays
    When I wait for 15 minutes
    Then temporary status bar displays "No Recent Glucose"
    When I open CGM manager
      And I open CGM Simulator settings
      And I setup CGM Simulator
        | Model    | Constant |
        | Constant | 200      |
      And I close cgm manager
    Then closed loop displays
    When I open bolus setup
    Then warning title displays "No Recent Glucose Data"
    When I tap "Enter Fingerstick Glucose"
    Then bolus screen displays
    When I set bolus screen values
      | FingerstickGlucose | 400 |
      | Bolus              | 5   |
    Then alert displays within 5 minutes
      | Title | Bolus Recommendation Updated |
    When I acknowledge alert
    Then bolus field displays value 0
    When I set bolus screen values
      | Bolus  | .5  |
      And I deliver and authenticate bolus
    Then temporary status bar displays current bolus progress
      And cgm pill displays value "200"
      
@LOOP-5207
Scenario: Bolus - Fingerstick Glucose Min and Max when CGM data is unavailable
    Given app is launched and intialy setup
    Then closed loop displays
    When I open CGM manager
      And I open CGM Simulator settings
      And I setup CGM Simulator
        | Model | SignalLoss |
      And I close cgm manager
    Then closed loop displays
    When I wait for 15 minutes
    Then temporary status bar displays "No Recent Glucose"
    When I open bolus setup
    Then warning title displays "No Recent Glucose Data"
    When I tap "Enter Fingerstick Glucose"
    Then bolus screen displays
    When I set bolus screen values
      | FingerstickGlucose |  9 |
      | Bolus              | .2 |
    Then warning title displays "No Bolus Recommended"
    When I tap Save without Bolusing button
    Then alert displays
      | Title  | Glucose Entry Out of Range |
    When I acknowledge alert
      And I set bolus screen values
        | FingerstickGlucose | 10 |
        | Bolus              | .2 |
      And I deliver and authenticate bolus
    Then temporary status bar displays current bolus progress
    When I wait for 15 minutes
    Then temporary status bar displays "No Recent Glucose"
    When I open bolus setup
    Then warning title displays "No Recent Glucose Data"
    When I tap "Enter Fingerstick Glucose"
    Then bolus screen displays
    When I set bolus screen values
      | FingerstickGlucose | 601 |
      | Bolus              | .2  |
      And I tap Save without Bolusing button
    Then alert displays
      | Title  | Glucose Entry Out of Range |
    When I acknowledge alert
      And I set bolus screen values
        | FingerstickGlucose | 600 |
        | Bolus              | .2  |
      And I deliver and authenticate bolus
    Then temporary status bar displays current bolus progress

@LOOP-5265
Scenario: Bolus - No Bolus Recommended Warning displays: glucose prediction within or below Correction Range
    Given app is launched and intialy setup
    Then closed loop displays
    When I open bolus setup
    Then warning title displays "No Bolus Recommended"
    When I set bolus screen values
      | Bolus  |  2  |
      And I deliver and authenticate bolus
    Then temporary status bar displays current bolus progress
    When I open bolus setup
    Then warning title displays "No Bolus Recommended"

@LOOP-5272
Scenario: Bolus - No Bolus Recommended Warning displays: current glucose below Glucose Safety Limit
    Given app is launched and intialy setup
    Then closed loop displays
    When I open CGM manager
      And I open CGM Simulator settings
      And I setup CGM Simulator
        | Model            | Constant   |
        | Constant         | 75         |
        | BackfillGlucose  | 15 minutes |
    Then cgm pill displays value "75"
    When I add Carb Entry
      | CarbsAmmount | 20  |
    Then meal bolus screen displays
    When I set bolus screen values
      | Bolus   |  0  |
      And I tap Save without Bolusing button
      And I wait for 15 seconds
    Then Active Carbohydrates displays value "20g"
    When I open bolus setup
    Then warning title does not display "No Bolus Recommended"
    When I navigate back
      And I open settings
      And I tap Therapy Settings
      And I set glucose safety limit value to 77 mg/dL
      And I confirm and save settings
    Then Glucose Safety Limit is set to 77 mg/dL
    When I tap Done
      And I close settings screen
    Then closed loop displays
    When I open bolus setup
    Then warning title displays "No Bolus Recommended"
      And bolus field displays value "0"
    When I tap Enter Bolus button
      And I set bolus screen values
        | Bolus  |  1  |
      And I deliver and authenticate bolus
    Then temporary status bar displays current bolus progress
