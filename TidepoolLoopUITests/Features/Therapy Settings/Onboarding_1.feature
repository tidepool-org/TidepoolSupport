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
Scenario: Therapy Settings Acceptance Flow - Glucose Safety Limit - Guardrails
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
Scenario: Therapy Settings Acceptance Flow - Correction Range
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
      And I add new Correction Range schedule item
        | Time    | MinValue | MaxValue |
        | 8:30 AM | 100      | 110      |
      And I edit 2nd scheduled item of Correction Range
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
    When I edit 2nd scheduled item of Correction Range
      | MinValue |
      | 87       |
    Then Correction Values message appears with warning indicators
      | MinValue | MaxValue | MessageIndicator |
      | red      | orange   | red              |
    When I edit 2nd scheduled item of Correction Range
      | MinValue |
      | 99       |
    Then Correction Values message appears with warning indicators
      | MinValue | MaxValue | MessageIndicator |
      | orange   | orange   | orange           |
    When I edit 2nd scheduled item of Correction Range
      | MinValue |
      | 126      |
    Then Correction Values message appears with warning indicators
      | MinValue | MaxValue | MessageIndicator |
      | orange   | orange   | orange           |
    When I navigate back to Glucose Safety Limit edit screen
      And I set glucose safety limit value to 88 mg/dL
      And I confirm and save settings
      And I navigate to Correction Range edit screen
      And I edit 2nd scheduled item of Correction Range
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

@LOOP-2400
Scenario: Therapy Settings Acceptance Flow - Guardrails - Pre-Meal Preset
    Given app is launched
    When I skip onboarding to Therapy Settings
      And I navigate to Glucose Safety Limit edit screen
      And I set glucose safety limit value to 67 mg/dL
      And I confirm and save settings
      And I navigate to Correction Range edit screen
      And I edit 1st scheduled item of Correction Range
        | MinValue | MaxValue |
        | 87       | 110      |
      And I confirm and save settings
      And I navigate to Pre-Meal Preset educational screen
    Then possible actions are
      | <Back    |
      | Close    |
      | Continue |
    When I tap Continue
    Then Pre-Meal Preset edit screen displays with possible actions
      | <Back           |
      | Close           |
      | Confirm Setting |
      | Information     |
    When I tap information circle
    Then Pre-Meal Preset information screen displays with possible actions
      | Close |
    When I close information screen
      And I edit 1st scheduled item of Pre-Meal Preset
        | MaxValue |
        | 88       |
    Then High Pre-Meal Value message appears with orange warning indicators
    When I tap Confirm Setting
    Then alert 'Save Pre-Meal Range?' appears
    When I tap Continue in alert window
    Then Workout Preset education screen displays
    When I navigate back
      And I edit 1st scheduled item of Pre-Meal Preset
        | MinValue |
        | highest  |
    Then Pre-Meal Values message appears with warning indicators
      | MinValue | MaxValue | MessageIndicator |
      | orange   | orange   | orange           |
      And pre-meal preset of 1st scheduled item displays values
        | MinValue | MaxValue |
        | 88       | 88       |
    When I tap Confirm Setting
      And I tap Go Back in alert window
      And I edit 1st scheduled item of Pre-Meal Preset
        | MaxValue |
        | 130      |
    Then Pre-Meal Values message appears with warning indicators
      | MinValue | MaxValue | MessageIndicator |
      | orange   | red      | red              |
    When I edit 1st scheduled item of Pre-Meal Preset
      | MinValue |
      | 67       |
    Then High Pre-Meal Value message appears with red warning indicators
    When I confirm and save settings
      And I navigate to the Therapy Settings confirmation screen
    Then Pre-Meal Preset section on Therapy Settings screen displays
        | MinValue | MaxValue |
        | 67       | 130      |
    When I save settings and finish the onboarding
      And I pair CGM simulator
      And I pair Pump simulator
      And I open Presets
    Then Pre-Meal Preset section on Presets screen displays
        | MinValue | MaxValue |
        | 67       | 130      |

@LOOP-2414
Scenario: Therapy Settings Acceptance Flow - Guardrails - Workout Preset
    Given app is launched
    When I skip onboarding to Therapy Settings
      And I navigate to Workout Preset educational screen
    Then possible actions are
      | <Back    |
      | Close    |
      | Continue |
    When I tap Continue
    Then Workout Preset edit screen displays with possible actions
      | <Back           |
      | Close           |
      | Confirm Setting |
      | Information     |
    When I tap information circle
    Then Workout Preset information screen displays with possible actions
      | Close |
    When I close information screen
      And I edit 1st scheduled item of Workout Preset
        | MinValue | MaxValue |
        | lowest   | 180      |
    Then Low Workout Value message appears with red warning indicators
    When I edit 1st scheduled item of Workout Preset
        | MaxValue |
        | 181      |
    Then Workout Values message appears with warning indicators
      | MinValue | MaxValue | MessageIndicator |
      | red      | orange   | red              |
    When I edit 1st scheduled item of Workout Preset
        | MaxValue |
        | 130      |
    Then Low Workout Value message appears with red warning indicators
    When I edit 1st scheduled item of Workout Preset
        | MinValue |
        | 125      |
      And I tap Confirm Setting
    Then Carb Ratios education screen displays
    When I navigate back to Pre-Meal Preset edit screen
      And I edit 1st scheduled item of Pre-Meal Preset
        | MaxValue | MinValue |
        | 115      | 111      |
      And I tap Confirm Setting
      And I navigate back to Correction Range edit screen
      And I edit 1st scheduled item of Correction Range
        | MaxValue | MinValue |
        | 125      | 115      |
      And I navigate back to Glucose Safety Limit edit screen
      And I set glucose safety limit value to 109 mg/dL
      And I confirm and save settings
      And I navigate to Workout Preset edit screen
      And I edit 1st scheduled item of Workout Preset
        | MinValue |
        | lowest   |
    Then Low Workout Value message appears with red warning indicators
    When I edit 1st scheduled item of Workout Preset
        | MaxValue |
        | 124      |
    Then Workout Values message appears with warning indicators
      | MinValue | MaxValue | MessageIndicator |
      | red      | orange   | red              |
      And workout preset of 1st scheduled item displays values
        | MinValue | MaxValue |
        | 109      | 124      |
    When I tap Confirm Setting
    Then alert 'Save Workout Range?' appears
    When I tap Continue in alert window
    Then Carb Ratios education screen displays
    When I navigate back
    When I edit 1st scheduled item of Workout Preset
        | MaxValue |
        | highest  |
    Then Workout Values message appears with warning indicators
      | MinValue | MaxValue | MessageIndicator |
      | red      | red      | red              |
      And workout preset of 1st scheduled item displays values
        | MinValue | MaxValue |
        | 109      | 250      |
    When I confirm and save settings
      And I navigate to the Therapy Settings confirmation screen
    Then Workout Preset section on Therapy Settings screen displays
        | MinValue | MaxValue |
        | 109      | 250      |
    When I save settings and finish the onboarding
      And I pair CGM simulator
      And I pair Pump simulator
      And I open Presets
    Then Workout Preset section on Presets screen displays
        | MinValue | MaxValue |
        | 109      | 250      |

@LOOP-1729
Scenario: Therapy Settings Acceptance Flow - Carb Ratio
    Given app is launched
    When I skip onboarding to Therapy Settings
      And I navigate to Carb Ratios educational screen
    Then possible actions are
      | <Back    |
      | Close    |
      | Continue |
    When I tap Continue
    Then Carb Ratios edit screen displays with possible actions
      | <Back           |
      | Edit            |
      | Add             |
      | Confirm Setting |
      | Information     |
    When I tap information circle
    Then Carb Ratios information screen displays with possible actions
      | Close |
    When I close information screen
      And I edit 1st scheduled item of Carb Ratios
        | WholeNumber | Decimal |
        | 3           | 9       |
    Then Low Carb Ratio message appears with orange warning indicators
    When I tap Confirm Setting
    Then alert 'Save Carb Ratios?' appears
    When I tap Go Back in alert window
      And I edit 1st scheduled item of Carb Ratios
      | WholeNumber | Decimal |
      | 4           | 0       |
    Then no warning message displays
    When I edit 1st scheduled item of Carb Ratios
      | WholeNumber | Decimal |
      | 2           | 0       |
    Then Low Carb Ratio message appears with red warning indicators
    When I confirm and save settings
      And I navigate back
      And I add new Carb Ratios schedule item
        | Time     | WholeNumber | Decimal |
        | 12:30 AM | 28          | 1       |
    Then Carb Ratios of 2nd scheduled item displays values
      | Time     | Value |
      | 12:30 AM | 28.1  |
      And Carb Ratios message appears with warning indicators
        | Item 1 | Item 2 | MessageIndicator |
        | red    | orange | red              |
    When I add new Carb Ratios schedule item
      | Time    | WholeNumber | Decimal |
      | 1:00 AM | 150         | 0       |
    Then Carb Ratios of 3rd scheduled item displays values
      | Time    | Value |
      | 1:00 AM | 150   |
      And Carb Ratios message appears with warning indicators
        | Item 1 | Item 2 | Item 3 | MessageIndicator |
        | red    | orange | red    | red              |
    When I add new Carb Ratios schedule item
      | Time    | WholeNumber | Decimal |
      | 1:30 AM | 28          | 0       |
    Then Carb Ratios of 4th scheduled item displays values
      | Time    | Value |
      | 1:30 AM | 28    |
      And Carb Ratios message appears with warning indicators
        | Item 1 | Item 2 | Item 3 | Item 4 | MessageIndicator |
        | red    | orange | red    | none   | red              |
    When I tap Edit
      And I remove the 3rd item
    Then 3 items display in the list
    When I tap Done
      And I confirm and save settings
      And I navigate to the Therapy Settings confirmation screen
    Then Carb Ratios section on Therapy Settings screen displays
        | Time     | Value |
        | 12:00 AM | 2     |
        | 12:30 AM | 28.1  |
        | 1:30 AM  | 28    |
    When I save settings and finish the onboarding
      And I pair CGM simulator
      And I pair Pump simulator
      And I open settings
      And I tap Therapy Settings
    Then Carb Ratios section on Therapy Settings screen displays
        | Time     | Value |
        | 12:00 AM | 2     |
        | 12:30 AM | 28.1  |
        | 1:30 AM  | 28    |
