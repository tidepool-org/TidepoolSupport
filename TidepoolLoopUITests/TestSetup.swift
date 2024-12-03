//
//  SetupXCUIApp.swift
//  TidepoolSupport
//
//  Created by Petr Žywczok on 14.11.2024.
//

import XCTest
import Foundation
import LoopUITestingKit

let app = XCUIApplication(bundleIdentifier: ProcessInfo.processInfo.environment["bundleIdentifier"]!)
let systemSettings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
let springBoard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

class TestSetup {
    static let basicWait = Double(5)
    static let longWait = Double(20)
}
