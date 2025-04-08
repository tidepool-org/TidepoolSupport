@Carbohydrates
Feature: Carbohydrates

@LOOP-1764
Scenario: View & Edit Carbohydrates
    Given app is launched
    When I skip all of onboarding
    Then closed loop displays
    When I add Carb Entry
        | CarbsAmmount | 40   |
        | FoodType     | Fast |
      And I deliver and authenticate bolus
      And I open Active Carbohydrates details
    Then the latest Carbohydrates record displays
        | CarbsAmount | 40   |
        | FoodType    | Fast |

@LOOP-2049
Scenario: Add Carb Entry - Editable field functionality
    Given app is launched
    When I skip all of onboarding
    Then closed loop displays
    When I set Carb Entry
      | FoodType | Fast |
    Then Carb Entry displays
      | AbsorbtionTime | 30 min |
    When I add Carb Entry
        | CarbsAmmount   | 40         |
        | ConsumeTime    | -5 minutes |
        | AbsorbtionTime | 30 minutes |
        | FoodType       | Other      |
      And I navigate back
    When I press decrease button "2" times to update Carb Entry time
    Then Consume Time displays updated value
    When I press increase button "1" time to update Carb Entry time
    Then Consume Time displays updated value
      And food collection contains food types
        | FAST   |
        | MEDIUM |
        | SLOW   |
        | OTHER  |
      And Carb Entry displays the most recently set data
    When I tap Continue on Carb Entry screen
      And I deliver and authenticate bolus
    Then temporary status bar displays current bolus progress
