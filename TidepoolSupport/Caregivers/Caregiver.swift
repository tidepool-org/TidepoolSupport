//
//  Caregiver.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/10/23.
//

import Foundation


enum InvitationStatus: String, Equatable {
    case pending
    case accepted
    case declined
    case resent
}

struct Caregiver: Identifiable, Equatable {
    let name: String
    let email: String
    let status: InvitationStatus
    let id: String
    
    func updateStatus(status: InvitationStatus) -> Caregiver {
        Caregiver(name: name, email: email, status: status, id: id)
    }
}

extension Caregiver {
    static var mockPending: Caregiver {
        return Caregiver(name: "Paloma Porpoise", email: "name@email.com", status: .pending, id: "1234")
    }

    static var mockAccepted: Caregiver {
        return Caregiver(name: "Sally Seaweed", email: "name@email.com", status: .accepted, id: "12345")
    }
}

