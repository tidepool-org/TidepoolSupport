@BasalRates
Feature: Basal Rates

@LOOP-2476
Scenario: Basal Schedule Modification
    Given app is launched
    When I skip all of onboarding
      And I navigate to Basal Rates
      And I edit 1st scheduled item of Basal Rates
        | WholeNumber | Decimal |
        | 2           | 10      |
      And I tap Save and authenticate new Basal Rates
    Then Basal Rates section on Therapy Settings screen displays
        | Value |
        | 2.1   |

@LOOP-1768
Scenario: Verify Closed Loop Basal Changes
    Given app is launched
    When I skip all of onboarding
    Then closed loop displays
    When I store the X axis period
      And I change orientation to Landscape
    Then closed loop does not display
      And graphs displays longer time period in landscape view
    When I change orientation to Portrait
      And I open Insulin Delivery
    Then modulation of Basal Rates displays
