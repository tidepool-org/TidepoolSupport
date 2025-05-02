@Presets
Feature: Presets

@LOOP-2115
Scenario: Warning for guardrail Pre-Meal Range
    Given app is launched
    When I skip all of onboarding
      And I update Glucose Safety limit value to 75 mg/dL
      And I dismiss Therapy Settings
      And I update Pre-Meal Correction Range
        | MinValue | lowest |
    Then Correction Range is set to value
        | MinValue | 75 |
    When I dismiss Presets
      And I update Glucose Safety limit value to 67 mg/dL
    Then Low Glucose Safety Limit message appears with red warning indicators
      And alert 'Save Glucose Safety Limit?' appears
    When I tap Continue in alert window
      And I authenticate new Glucose Safety Limit
      And I dismiss Therapy Settings
      And I update Pre-Meal Correction Range
        | MinValue | lowest  |
        | MaxValue | highest |
    Then High Correction Value message appears with red warning indicators
      And Correction Range is set to value
        | MinValue | 67  |
        | MaxValue | 130 |
    When I tap Save
    Then Pre-Meal Presets preview displays
      | Correction Range | 67-130                           |
      | Warning          | value you have entered is higher |

@LOOP-1765
Scenario: Enable Workout Preset
    Given app is launched
    When I skip all of onboarding
      And I open Workout Preset
      And I tap Start Preset
    Then Workout card moves above the All Presets list
    When I tap Done
    Then temporary status bar displays
      | Title  | Workout Preset  |
      | Active | on indefinitely |
      And Presets toolbar icon displays as reverse icon
    When I tap Workout Preset status bar
      And I adjust Preset Duration to "11:09 AM"
    Then temporary status bar displays
      | Title  | Workout Preset    |
      | Active | on until 11:09 AM |
      And Workout Preset bottom tray displays duration "on until 11:09 AM"
    When I tap Close button
    Then Workout Preset bottom tray does not display
    When I tap Workout Preset status bar
      And I tap End Preset button
    Then Workout Preset bottom tray does not display
      And Workout Preset temporary status bar does not display
      And Presets toolbar icon displays as normal icon
    When I open Workout Preset
      And I tap Start Preset
      And I tap Workout Preset card
      And I adjust Preset Duration to "+1 minute"
    Then Workout Preset ends within "1" minute
      And Workout Preset temporary status bar does not display
      And Presets toolbar icon displays as normal icon

@LOOP-1766
Scenario: Enable Pre-Meal Preset
    Given app is launched
    When I skip all of onboarding
      And I open Pre-Meal Preset
      And I tap Start Preset
    Then Pre-Meal card moves above the All Presets list
    When I tap Done
    Then temporary status bar displays
      | Title  | Pre-Meal Preset      |
      | Active | on until carbs added |
      And Presets toolbar icon displays as reverse icon
    When I tap Pre-Meal Preset status bar
    Then Pre-Meal Preset bottom tray does display
    When I tap Close button
    Then Pre-Meal Preset bottom tray does not display
    When I open Insulin Delivery
    Then latest temporary basal rate reflects the new lower target range
    When I navigate back
      And I tap Pre-Meal Preset status bar
      And I tap End Preset button
    Then Pre-Meal Preset bottom tray does not display
      And Pre-Meal Preset temporary status bar does not display
      And Presets toolbar icon displays as normal icon
    When I open Insulin Delivery
    Then latest temporary basal rate reflects the new normal target range
