Feature: Shared Tests

Scenario: Skipping Onboarding Leads To Homepage With Simulators
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
      And I switch to tidepool loop app
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
