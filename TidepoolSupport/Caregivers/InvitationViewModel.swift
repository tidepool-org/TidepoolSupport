//
//  InvitationManager.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/8/23.
//

import Foundation

class InvitationViewModel: ObservableObject {

    @Published var nickname: String = ""
    @Published var email: String = ""

    var isEmailValid: Bool {
        let emailFormat = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)

    }

    @Published var urgentLowEnabled: Bool = true
    @Published var urgentLowThreshold: Double = 55
    var urgentLowThresholdValues: [Double] {
        return Array(stride(from: 40, through: 55, by: 5))
    }

    @Published var lowEnabled: Bool = false
    @Published var lowThreshold: Double = 70
    @Published var lowDelay: TimeInterval = TimeInterval(30 * 60)
    var lowThresholdValues: [Double] {
        return Array(stride(from: 60, through: 100, by: 5))
    }
    var lowDelayValues: [Double] {
        return Array(stride(from: TimeInterval(minutes: 30), through: TimeInterval(hours: 2), by: TimeInterval(minutes: 5)))
    }

    @Published var highEnabled: Bool = false
    @Published var highThreshold: Double = 250
    @Published var highDelay: TimeInterval = TimeInterval(hours: 1)
    var highThresholdValues: [Double] {
        return Array(stride(from: 120, through: 400, by: 10))
    }
    var highDelayValues: [Double] {
        return Array(stride(from: TimeInterval(minutes: 30), through: TimeInterval(hours: 2), by: TimeInterval(minutes: 5)))
    }

    @Published var notLoopingEnabled: Bool = false
    @Published var notLoopingDelay: TimeInterval = TimeInterval(hours: 1)
    var notLoopingDelayValues: [Double] {
        return Array(stride(from: TimeInterval(minutes: 30), through: TimeInterval(hours: 2), by: TimeInterval(minutes: 5)))
    }

    @Published var noCommunicationEnabled: Bool = false
    @Published var noCommunicationDelay: TimeInterval = TimeInterval(60 * 60)
    var noCommunicationDelayValues: [Double] {
        return Array(stride(from: TimeInterval(minutes: 30), through: TimeInterval(hours: 2), by: TimeInterval(minutes: 5)))
    }

    let valueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    let timeIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        return formatter
    }()

    func submit() async throws {
        try await mockSubmit()
    }

    // Mock stuff
    var triedMockSubmit: Bool = false
    func mockSubmit() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        if !triedMockSubmit {
            triedMockSubmit = true
            throw MockNetworkError.serverError
        }
        print("Success!")
    }
}

enum MockNetworkError: Error {
    case serverError
}
extension MockNetworkError : LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serverError:
            return LocalizedString("Network Error.", comment: "")
        }
    }
    public var recoverySuggestion: String? {
        switch self {
        case .serverError:
            return LocalizedString("Make sure your device has service and then tap Send Invite to resend your invitation.", comment: "")
        }
    }
}
