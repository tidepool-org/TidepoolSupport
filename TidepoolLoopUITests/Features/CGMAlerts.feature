@CGMAlerts
Feature: CGM Alerts

@LOOP-1601
Scenario: CGM Error and State Handling - Status Bar Displays
    Given app is launched
    When I skip all of onboarding
      And I open CGM manager
      And I open CGM Simulator settings
      And I setup CGM Simulator
        | Model                | Constant   |
        | Constant             | 200        |
        | CgmUpperLimit        | 199.9      |
        | BackfillGlucose      | 3 hours    |
    Then cgm pill displays value "HIGH"
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | Model                | Constant   |
        | Constant             | 1          |
        | CgmLowerLimit        | 1.1        |
        | BackfillGlucose      | 3 hours    |
    Then cgm pill displays value "LOW"
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | Trend | Rising |
    Then cgm pill displays trend "Rising"
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | Trend | Rising fast |
    Then cgm pill displays trend "Rising fast"
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | Trend | Flat |
    Then cgm pill displays trend "Flat"
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | Trend | Falling |
    Then cgm pill displays trend "Falling"
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | Trend | Falling fast |
    Then cgm pill displays trend "Falling fast"
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | IssueAlert | Issue an immediate alert |
    Then alert displays
        | Title | Alert: FG Title        |
        | Body  | Alert: Foreground Body |
    When I acknowledge alert
      And I tap Done
    Then cgm pill displays alert "Alert: FG Title"
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | IssueAlert      | Retract any alert above |
        | BackfillGlucose | 3 hours                 |
    Then cgm pill doesn't display alert "Alert: FG Title"
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | IssueAlert      | Issue a critical immediate alert |
    Then alert displays
        | Title | Critical Alert: FG Title        |
        | Body  | Critical Alert: Foreground Body |
    When I acknowledge alert
      And I tap Done
    Then cgm pill displays alert "Critical Alert: FG Title"
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | IssueAlert        | Retract any alert above |
        | PercentCompleted  | 79                      |
        | WarningThreshold  | 80                      |
        | CriticalThreshold | 90                      |
        | BackfillGlucose   | 3 hours                 |
    Then CGM lifecycle progress bar displays
        | Progress | 79%       |
        | State    | normalCGM |
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | PercentCompleted  | 80      |
        | BackfillGlucose   | 3 hours |
    Then CGM lifecycle progress bar displays
        | Progress | 80%     |
        | State    | warning |
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | PercentCompleted  | 89      |
        | BackfillGlucose   | 3 hours |
    Then CGM lifecycle progress bar displays
        | Progress | 89%     |
        | State    | warning |
    When I open CGM Simulator settings from Home screen
      And I setup CGM Simulator
        | PercentCompleted  | 90      |
        | BackfillGlucose   | 3 hours |
    Then CGM lifecycle progress bar displays
        | Progress | 90%      |
        | State    | critical |
