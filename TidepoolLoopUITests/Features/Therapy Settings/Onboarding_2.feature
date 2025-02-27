@Onboarding
Feature: Onboarding

@LOOP-1682
Scenario: Therapy Settings Acceptance Flow - Basal Rates
    Given app is launched
    When I skip onboarding to Therapy Settings
      And I navigate to Carb Ratios edit screen
      And I edit 1st scheduled item of Carb Ratios
        | WholeNumber | Decimal |
        | 2           | 0       |
      And I confirm and save settings
    Then Basal Rates education screen displays
      And possible actions are
        | <Back    |
        | Close    |
        | Continue |
    When I tap Continue
    Then Basal Rates edit screen displays with possible actions
      | <Back           |
      | Edit            |
      | Add             |
      | Confirm Setting |
      | Information     |
    When I tap information circle
    Then Basal Rates information screen displays with possible actions
      | Close |
    When I close information screen
     And I tap Confirm Setting
    Then Delivery Limits education screen displays
      And possible actions are
        | <Back    |
        | Close    |
        | Continue |
    When I tap Continue
    Then Delivery Limits edit screen displays with possible actions
      | <Back           |
      | Confirm Setting |
      | 2x Information  |
    When I edit item of Maximum Basal Rate
      | WholeNumber | Decimal |
      | 30          | 00      |
    Then High Maximum Basal Rate message appears with orange warning indicators
    When I confirm and save settings
      And I navigate back to Basal Rates edit screen
      And I tap Edit
      And I remove the 2nd item
      And I add new Basal Rates schedule item
      | Time     | WholeNumber | Decimal |
      | 12:30 AM | highest     | highest |
    Then Basal Rates of 2nd scheduled item displays values
      | Time     | Value |
      | 12:30 AM | 30    |
    When I edit 1st scheduled item of Basal Rates
      | WholeNumber | Decimal |
      | lowest      | lowest  |
    Then Basal Rates of 1st scheduled item displays values
      | Time     | Value |
      | 12:00 AM | 0     |
    When I tap Confirm Setting
      And I navigate to the Therapy Settings confirmation screen
    Then Basal Rates section on Therapy Settings screen displays
        | Time     | Value |
        | 12:00 AM | 0     |
        | 12:30 AM | 30    |
    When I save settings and finish the onboarding
      And I pair CGM simulator
      And I pair Pump simulator
      And I open settings
      And I tap Therapy Settings
    Then Basal Rates section on Therapy Settings screen displays
        | Time     | Value |
        | 12:00 AM | 0     |
        | 12:30 AM | 30    |

@LOOP-1733
Scenario: Therapy Settings Acceptance Flow - Insulin Model
    Given app is launched
    When I skip onboarding to Therapy Settings
      And I navigate to Insulin Model educational screen
    Then possible actions are
        | <Back    |
        | Close    |
        | Continue |
    When I tap Continue
    Then Insulin Model edit screen displays with possible actions
      | <Back           |
      | Confirm Setting |
      | Information     |
    When I tap information circle
    Then Insulin Model information screen displays with possible actions
      | Close |
    When I close information screen
      And I select Rapid-Acting – Children insulin model
      And I tap Confirm Setting
      And I navigate to the Therapy Settings confirmation screen
    Then Insulin Model section on Therapy Settings screen displays
        | Insulin Model           |
        | Rapid-Acting – Children |
    When I save settings and finish the onboarding
      And I pair CGM simulator
      And I pair Pump simulator
      And I open settings
      And I tap Therapy Settings
    Then Insulin Model section on Therapy Settings screen displays
        | Insulin Model           |
        | Rapid-Acting – Children |

@LOOP-1743
Scenario: Therapy settings Acceptance Flow - Insulin Sensitivity
    Given app is launched
    When I skip onboarding to Therapy Settings
      And I navigate to Insulin Sensitivities educational screen
    Then possible actions are
        | <Back    |
        | Close    |
        | Continue |
    When I tap Continue
    Then Insulin Sensitivities edit screen displays with possible actions
      | <Back           |
      | Edit            |
      | Add             |
      | Confirm Setting |
      | Information     |
    When I tap information circle
    Then Insulin Sensitivities information screen displays with possible actions
      | Close |
    When I close information screen
    When I edit 1st scheduled item of Insulin Sensitivity
      | Time        | Value |
      | 12:00 AM    | 10    |
    Then Low Insulin Sensitivity message appears with red warning indicators
    When I tap Edit
      And I remove the 2nd item
    Then 1 item displays in the list
    When I add new Insulin Sensitivity schedule item
        | Time     | Value |
        | 12:30 AM | 15    |
    Then Insulin Sensitivity of 2nd scheduled item displays values
      | Time     | Value |
      | 12:30 AM | 15    |
      And Insulin Sensitivities message appears with warning indicators
        | Item 1 | Item 2 | MessageIndicator |
        | red    | orange | red              |
    When I tap Confirm Setting
    Then alert 'Save Insulin Sensitivities?' appears
    When I tap Continue in alert window
    Then Therapy Settings overview screen displays
    When I navigate back
      And I edit 1st scheduled item of Insulin Sensitivity
      | Time        | Value |
      | 12:00 AM    | 16    |
    Then Low Insulin Sensitivity message appears with orange warning indicators
    When I tap Confirm Setting
    Then alert 'Save Insulin Sensitivities?' appears
    When I tap Go Back in alert window
      And I tap 2nd scheduled item
      And I edit 2nd scheduled item of Insulin Sensitivity
      | Time        | Value |
      | 12:30 AM    | 500   |
    Then High Insulin Sensitivity message appears with red warning indicators
    When I edit 2nd scheduled item of Insulin Sensitivity
      | Time        | Value |
      | 12:30 AM    | 400   |
    Then High Insulin Sensitivity message appears with orange warning indicators
    When I confirm and save settings
    Then Insulin Sensitivities section on Therapy Settings screen displays
        | Time     | Value |
        | 12:00 AM | 16    |
        | 12:30 AM | 400   |
    When I save settings and finish the onboarding
      And I pair CGM simulator
      And I pair Pump simulator
      And I open settings
      And I tap Therapy Settings
    Then Insulin Sensitivities section on Therapy Settings screen displays
        | Time     | Value |
        | 12:00 AM | 16    |
        | 12:30 AM | 400   |
