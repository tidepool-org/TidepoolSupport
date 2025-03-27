@SimpleBolus
Feature: Simple Bolus

@LOOP-5200
Scenario: Simple Bolus Calculator - Current Glucose Min and Max
    Given app is launched and intialy setup
    When I open settings
      And I turn off closed loop
      And I close settings screen
    Then open loop displays
    When I open bolus setup
    Then simple bolus calculator displays
    When I set current glucose value 9
        And I set bolus value .2
    Then glucose range warning displays
    When I set current glucose value 10
        And I set bolus value .2
        And I save and deliver and authenticate bolus
    Then cgm pill displays value "10"
    When I open bolus setup
    Then simple bolus calculator displays
    When I set current glucose value 601
        And I set bolus value .2
    Then glucose range warning displays
    When I set current glucose value 600
        And I set bolus value .2
        And I save and deliver and authenticate bolus
    Then cgm pill displays value "600"
    
