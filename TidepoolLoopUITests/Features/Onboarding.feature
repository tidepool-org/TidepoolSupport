@Onboarding
Feature: Onboarding

@LOOP-1784
Scenario: Therapy Flow - Therapy settings overview screen
    Given app is launched
    When I skip onboarding to Therapy Settings
      And I navigate to Therapy Settings from onboarding
    Then Therapy Settings screen displays
      | Section               | Units       |
      | Prescription          |             |
      | Glucose Safety Limit  | mg/dL       |
      | Correction Range      | mg/dL       |
      | Pre-Meal Preset       | mg/dL       |
      | Workout Preset        | mg/dL       |
      | Carb Ratios           | g/U         |
      | Basal Rates           | U/hr, U/day |
      | Delivery Limits       | U/hr, U     |
      | Insulin Model         |             |
      | Insulin Sensitivities | mg/dL/U     |
      And Prescription section displays Dr. name and date of prescription
      And possible actions are
        | <Back    |
        | Close    |
        | Continue |

@LOOP-1672
Scenario: Therapy settings acceptance flow - Glucose Safety Limit - Guardrails
    Given app is launched
    When I skip onboarding to Therapy Settings
      And I navigate to Glucose Safety Limit edit screen
      And I set glucose safety limit value to 80 mg/dL
      And I tap Confirm Setting
    Then Correction Range education screen displays
    When I navigate back
      And I set glucose safety limit value to 67 mg/dL
    Then Low Glucose Safety Limit message appears with red warning indicators
    When I tap Confirm Setting
    Then alert 'Save Glucose Safety Limit?' appears
    When I tap Go Back in alert window
      And I set glucose safety limit value to 73 mg/dL
    Then Low Glucose Safety Limit message appears with orange warning indicators
    When I tap Confirm Setting
    Then alert 'Save Glucose Safety Limit?' appears
    When I tap Go Back in alert window
      And I set glucose safety limit value to 81 mg/dL
    Then High Glucose Safety Limit message appears with orange warning indicators
    When I tap Confirm Setting
    Then alert 'Save Glucose Safety Limit?' appears
    When I tap Go Back in alert window
    When I set glucose safety limit value to 110 mg/dL
    Then High Glucose Safety Limit message appears with red warning indicators
    When I tap Confirm Setting
    Then alert 'Save Glucose Safety Limit?' appears
    When I tap Continue in alert window
    When I navigate to the Therapy Settings confirmation screen
    Then Glucose Safety Limit is set to 110 mg/dL in the Onboarding overview
    When I save settings and finish the onboarding
      And I pair CGM simulator
      And I pair Pump simulator
      And I open settings
      And I tap Therapy Settings
    Then Glucose Safety Limit is set to 110 mg/dL

@LOOP-1608
Scenario: Therapy settings acceptance flow - Correction Range
    Given app is launched
    When I skip onboarding to Therapy Settings
      And I navigate to Correction Range educational screen
    Then possible actions are
      | <Back    |
      | Close    |
      | Continue |
    When I tap Continue
    Then Correction Range edit screen displays with possible actions
      | <Back           |
      | Edit            |
      | Add             |
      | Confirm Setting |
      | Information     |
    When I tap information circle
    Then Correction Range information screen displays with possible actions
      | Close |
    When I close information screen
      And I add 2 new correction range schedule items
      And I tap Edit
      And I remove the 2nd item
    Then 2 items display in the list
    When I tap Done
      And I add new correction range schedule item
        | Time    | MinValue | MaxValue |
        | 8:30 AM | 100      | 110      |
      And I edit 2nd scheduled item
        | MaxValue |
        | 126      |
    Then High Correction Value message appears with orange warning indicators
    When I tap Confirm Setting
    Then alert 'Save Correction Range(s)?' appears
    When I tap Continue in alert window
    Then Pre-Meal Preset education screen displays
    When I navigate back
      And I tap Confirm Setting
      And I tap Go Back in alert window
    Then Correction Range edit screen displays with possible actions
      | <Back           |
      | Edit            |
      | Add             |
      | Confirm Setting |
      | Information     |
    When I edit 2nd scheduled item
      | MinValue |
      | 87       |
    Then Correction Values message appears with warning indicators
      | MinValue | MaxValue | MessageIndicator |
      | red      | orange   | red              |
    When I edit 2nd scheduled item
      | MinValue |
      | 99       |
    Then Correction Values message appears with warning indicators
      | MinValue | MaxValue | MessageIndicator |
      | orange   | orange   | orange           |
    When I edit 2nd scheduled item
      | MinValue |
      | 126      |
    Then Correction Values message appears with warning indicators
      | MinValue | MaxValue | MessageIndicator |
      | orange   | orange   | orange           |
    When I navigate back to Glucose Safety Limit edit screen
      And I set glucose safety limit value to 88 mg/dL
      And I navigate to Correction Range edit screen
      And I edit 2nd scheduled item
        | MinValue |
        | lowest   |
    Then Correction Values message appears with warning indicators
      | MinValue | MaxValue | MessageIndicator |
      | orange   | orange   | orange           |
      And value for picker wheel is set to
        | MinValue |
        | 88       |
      And correction range of 2nd scheduled item displays values
        | MinValue | MaxValue |
        | 88       | 126      |
    When I tap Confirm Setting
      And I tap Continue in alert window
      And I navigate to the Therapy Settings confirmation screen
    Then Correction Range section on Therapy Settings screen displays
        | Time    | MinValue | MaxValue |
        |         | 115      | 125      |
        |         | 88       | 126      |
        | 8:30 AM | 100      | 110      |
    When I save settings and finish the onboarding
      And I pair CGM simulator
      And I pair Pump simulator
      And I open settings
      And I tap Therapy Settings
    Then Correction Range section on Therapy Settings screen displays
        | Time    | MinValue | MaxValue |
        |         | 115      | 125      |
        |         | 88       | 126      |
        | 8:30 AM | 100      | 110      |
