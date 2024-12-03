//
//  HomeSteps.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 19.11.2024.
//
import XCTest

class HomeSteps {
    let homeScreen = HomeScreen()
    
    // MARK: Actions
    
    func when_i_open_settings() {
        homeScreen.tapSettingsButton()
    }
    
    func when_i_initiate_premeal_setup() {
        homeScreen.tapPreMealButton()
    }
    
    func when_i_cancel_premeal_dialog() {
        homeScreen.tapPreMealDialogCancelButton()
    }
    
    func when_i_tap_x_loop_icon(closedLoopOn: Bool) {
        closedLoopOn ? homeScreen.tapLoopStatusClosed() : homeScreen.tapLoopStatusOpen()
    }
    
    func when_i_dismiss_closed_loop_status_alert() {
        homeScreen.tapLoopStatusAlertDismissButton()
    }
    
    func when_i_open_bolus_setup() {
        homeScreen.tapBolusEntry()
    }
    
    func when_i_open_carb_entry() {
        homeScreen.tapCarbEntry()
    }
    
    func when_i_open_pump_manager() {
        homeScreen.tapPumpPill()
    }
    
    // MARK: Verifications
    
    func then_closed_loop_displays() {
        XCTAssertTrue(homeScreen.hudStatusClosedLoopExists)
    }
    
    func then_open_loop_displays() {
        XCTAssert(homeScreen.hudStatusOpenLoopExists)
    }
    
    func then_premeal_button_is_x(buttonEnabled: Bool) {
        XCTAssertEqual(buttonEnabled, homeScreen.preMealButtonEnabled)
    }
    
    func then_closed_loop_x_alert_displays(onOff: String) {
        let _onOff = onOff.lowercased()
        
        if !((_onOff == "off") || (_onOff == "on")) {
            XCTFail("Illegal argument. Supported values are 'on' or 'off'")
        }
        
        XCTAssert(_onOff == "on" ? homeScreen.closedLoopOnAlertTitleExists : homeScreen.closedLoopOffAlertTitleExists)
    }
    
    func then_pump_pill_displays_value(displayedValue: String) {
        homeScreen.pumpPillDisplaysValue(value: displayedValue)
    }
}
