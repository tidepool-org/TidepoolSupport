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
    
    
@LOOP-3710
Scenario: Simple Bolus Calculator - Current Glucose values with decimal above 10 mmol/L can be entered
    Given app is launched and intialy setup
    When I open settings
        And I turn off closed loop
        And I close settings screen
    Then open loop displays
    When I open bolus setup
    Then simple bolus calculator displays
    When I set current glucose value 10.3
        And I set bolus value .2
        And I save and deliver and authenticate bolus
    Then cgm pill displays value "10"
    
    
@LOOP-5230
Scenario: Simple Bolus Calculator- Bolus field resets to zero after Current Glucose value is changed
    Given app is launched and intialy setup
    When I open settings
        And I turn off closed loop
        And I close settings screen
    Then open loop displays
    When I open bolus setup
    Then simple bolus calculator displays
    When I set current glucose value 200
        And I set bolus value 5
        And I set current glucose value 250
    Then bolus field displays value "0"

@LOOP-5298
Scenario: Simple Bolus Calculator - Happy Path flow (1 U, 100 mg/dL)
    Given app is launched and intialy setup
    When I open settings
        And I turn off closed loop
        And I close settings screen
    Then open loop displays
    When I open bolus setup
    Then simple bolus calculator displays
    When I set current glucose value 100
        And I set bolus value 1
        And I save and deliver and authenticate bolus
    Then cgm pill displays value "100"
