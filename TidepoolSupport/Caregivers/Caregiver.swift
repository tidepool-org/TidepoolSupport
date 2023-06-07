//
//  Caregiver.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/10/23.
//

import Foundation


enum InvitationStatus {
    case pending
    case accepted
    case declined
}

struct Caregiver: Identifiable {
    let name: String
    let email: String
    let status: InvitationStatus
    let id: String
}

extension Caregiver {
    static var mockPending: Caregiver {
        return Caregiver(name: "Paloma Porpoise", email: "name@email.com", status: .pending, id: "1234")
    }

    static var mockAccepted: Caregiver {
        return Caregiver(name: "Sally Seaweed", email: "name@email.com", status: .accepted, id: "12345")
    }
}

