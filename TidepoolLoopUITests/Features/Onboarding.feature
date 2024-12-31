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
    When I tap Go Back
      And I set glucose safety limit value to 73 mg/dL
    Then Low Glucose Safety Limit message appears with orange warning indicators
    When I tap Confirm Setting
    Then alert 'Save Glucose Safety Limit?' appears
    When I tap Go Back
      And I set glucose safety limit value to 81 mg/dL
    Then High Glucose Safety Limit message appears with orange warning indicators
    When I tap Confirm Setting
    Then alert 'Save Glucose Safety Limit?' appears
    When I tap Go Back
      And I set glucose safety limit value to 110 mg/dL
    Then High Glucose Safety Limit message appears with red warning indicators
    When I tap Confirm Setting
    Then alert 'Save Glucose Safety Limit?' appears
    When I confirm glucose safety limit in alert window
      And I navigate to the Therapy Settings confirmation screen
    Then Glucose Safety Limit is set to 110 mg/dL
    When I save settings and finish the onboarding
      And I pair CGM simulator
      And I pair Pump simulator
      And I open settings
      And I tap Therapy Settings
    Then Glucose Safety Limit is set to 6.1 mg/dL
