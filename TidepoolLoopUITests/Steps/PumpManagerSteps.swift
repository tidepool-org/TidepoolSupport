//
//  PumpManagerSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 20.11.2024.
//

import XCTest

class PumpManagerSteps {
    let pumpManagerScreen = PumpManagerScreen()
    
    // MARK: Actions
    
    func when_i_close_pump_manager() {
        pumpManagerScreen.tapPumpSimulatorDoneButton()
    }
    
    func when_i_suspend_insulin_delivery() {
        pumpManagerScreen.tapSuspendInsulinButton()
    }
    
    func when_i_resume_insulin_delivery() {
        pumpManagerScreen.tapResumeInsulinButton()
    }
    
    func when_i_open_pump_settings() {
        pumpManagerScreen.tapPumpManagerProgressImage()
    }
    
    func when_i_set_reservoir_remaining(remainingValue: String) {
        pumpManagerScreen.tapReservoirRemainingRow()
        pumpManagerScreen.tapReservoirRemainingTextField()
        pumpManagerScreen.clearReservoirRemainingTextField()
        pumpManagerScreen.setReservoirRemainingText(value: remainingValue)
        pumpManagerScreen.closeReservoirRemainingScreen()
    }
    
    func when_i_navigate_back_to_pump_manager() {
        pumpManagerScreen.tapPumpSettingsBackButton()
    }
    
    func when_i_select_detect_occlussion() {
        pumpManagerScreen.tapDetectOcclusionButton()
    }
    
    func when_i_select_resolve_occlusion() {
        pumpManagerScreen.tapResolveOcclusionButton()
    }
    
    func when_i_select_cause_pump_error() {
        pumpManagerScreen.tapCausePumpErrorButton()
    }
    
    func when_i_select_resolve_pump_error() {
        pumpManagerScreen.tapResolvePumpErrorButton()
    }
    
    // MARK: Verifications
    
    func then_pump_manager_displays() {
        XCTAssert(pumpManagerScreen.pumpSimulatorDisplayed)
    }
    
    func then_resume_insulin_delivery_displays() {
        XCTAssert(pumpManagerScreen.resumeInsulinButtonExists)
    }
    
    func then_suspend_insulin_delivery_displays() {
        XCTAssert(pumpManagerScreen.suspendInsulinButtonExists)
    }
}
