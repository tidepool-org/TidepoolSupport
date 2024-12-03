//
//  PumpManagerSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 20.11.2024.
//

import XCTest
import CucumberSwift

func pumpManagerSteps() {
    let pumpManagerScreen = PumpManagerScreen()
    
    // MARK: Actions
    
    When("I close pump manager") { _, _ in
        pumpManagerScreen.tapPumpSimulatorDoneButton()
    }
    
    When("I suspend insulin delivery") { _, _ in
        pumpManagerScreen.tapSuspendInsulinButton()
    }
    
    When("I resume insulin delivery") { _, _ in
        pumpManagerScreen.tapResumeInsulinButton()
    }
    
    When("I open pump settings") { _, _ in
        pumpManagerScreen.tapPumpManagerProgressImage()
    }
    
    When("I set reservoir remaining value {float}") { matches, _ in
        pumpManagerScreen.tapReservoirRemainingRow()
        pumpManagerScreen.tapReservoirRemainingTextField()
        pumpManagerScreen.clearReservoirRemainingTextField()
        pumpManagerScreen.setReservoirRemainingText(value: try matches.first(\.float))
        pumpManagerScreen.closeReservoirRemainingScreen()
    }
    
    When("I navigate back to pump manager") { _, _ in
        pumpManagerScreen.tapPumpSettingsBackButton()
    }
    
    When("I select detect occlussion") { _, _ in
        pumpManagerScreen.tapDetectOcclusionButton()
    }
    
    When("I select resolve occlusion") { _, _ in
        pumpManagerScreen.tapResolveOcclusionButton()
    }
    
    When("I select cause pump error") { _, _ in
        pumpManagerScreen.tapCausePumpErrorButton()
    }
    
    When("I select resolve pump error") { _, _ in
        pumpManagerScreen.tapResolvePumpErrorButton()
    }
    
    // MARK: Verifications
    
    Then("pump manager displays") { _, _ in
        XCTAssert(pumpManagerScreen.pumpSimulatorDisplayed)
    }
    
    Then("resume insulin delivery displays") { _, _ in
        XCTAssert(pumpManagerScreen.resumeInsulinButtonExists)
    }
    
    Then("suspend insulin delivery displays") { _, _ in
        XCTAssert(pumpManagerScreen.suspendInsulinButtonExists)
    }
}
