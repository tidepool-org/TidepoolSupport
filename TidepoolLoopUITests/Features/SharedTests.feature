Feature: Shared Tests

@LOOP-1561
Scenario: Skip All Onboarding from the Tidepool Loop launch screen & onboard simulators from fresh Install
    Given app is launched
    When I skip all of onboarding
    Then closed loop displays
    When I open settings
      And I open pump manager from settings
    Then pump manager displays
    When I close pump manager
      And I open cgm manager from settings
    Then cgm manager displays
    When I close cgm manager
      And I close settings screen
    Then closed loop displays

@LOOP-1605
Scenario: Alert Settings UI
    Given app is launched and intialy setup
    When I disable notifications and disable critical alerts
      And I return to tidepool loop app
      And I open settings
    Then alert warning image displays
    When I open alert management
    Then permissions alert warning image displays
    When I navigate to iOS permissions
    Then iOS permissions notifications disabled displays
      And iOS permissions critical alerts disabled displays
    When I navigate to manage iOS permissions
      And I enable notifications and disable critical alerts
      And I return to tidepool loop app
    Then iOS permissions notifications enabled displays
    When I navigate to manage iOS permissions
      And I enable notifications and enable critical alerts
      And I return to tidepool loop app
    Then iOS permissions critical alerts enabled displays

@LOOP-1713
Scenario: Configure Closed Loop Management
    Given app is launched and intialy setup
    Then closed loop displays
    When I open settings
      And I turn off closed loop
      And I close settings screen
    Then open loop displays
      And glucose chart caret doesn't display
    When I tap open loop icon
    Then closed loop off alert displays
    When I dismiss closed loop status alert
      And I open bolus setup
    Then simple bolus calculator displays
    When I close bolus screen
      And I open carb entry
    Then simple meal calculator displays
    When I close carbs entry screen
      And I open settings
      And I turn on closed loop
      And I close settings screen
    Then closed loop displays
      And glucose chart caret displays
    When I tap closed loop icon
    Then closed loop displays
    When I dismiss closed loop status alert
      And I open bolus setup
    Then bolus screen displays
    When I close bolus screen
      And I open carb entry
    Then carb entry screen displays

@LOOP-1636
Scenario: Pump Error And State Handling - Status Bar Displays
    Given app is launched and intialy setup
    When I open pump manager
      And I suspend insulin delivery
    Then resume insulin delivery displays
    When I close pump manager
    Then pump pill displays value "Insulin Suspended"
    When I open pump manager
      And I resume insulin delivery
    Then suspend insulin delivery displays
    When I open pump settings
      And I set reservoir remaining value 0
      And I navigate back to pump manager
      And I close pump manager
    Then pump pill displays value "No Insulin"
    When I open pump manager
      And I open pump settings
      And I set reservoir remaining value 15
      And I navigate back to pump manager
      And I close pump manager
    Then pump pill displays value "15 units remaining"
    When I open pump manager
      And I open pump settings
      And I set reservoir remaining value 45
      And I navigate back to pump manager
      And I close pump manager
    Then pump pill displays value "45 units remaining"
        When I open pump manager
      And I open pump settings
      And I select detect occlussion
      And I navigate back to pump manager
      And I close pump manager
    Then pump pill displays value "Pump Occlusion"
    When I open bolus setup
      And I set bolus value 2.1
      And I deliver and authenticate bolus
    Then notification displays
      | Title       | Body                      |
      | Bolus Issue | Pump is in an error state |
    When I open pump manager
      And I open pump settings
      And I select resolve occlusion
      And I select cause pump error
      And I navigate back to pump manager
      And I close pump manager
    Then pump pill displays value "Pump Error"
