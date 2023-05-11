//
//  CaregiverManager.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/11/23.
//

import Foundation
import TidepoolKit

class CaregiverManager: ObservableObject {
    @Published var caregivers: [Caregiver]

    var api: TAPI

    init(caregivers: [Caregiver], api: TAPI) {
        self.caregivers = caregivers
        self.api = api
    }
}


// MARK: - Mocks
extension TAPI {
    static var mock: TAPI {
        TAPI(clientId: "mock", redirectURL: URL(string: "https://mock.com/mock")!)
    }
}

extension CaregiverManager {
    static var mock: CaregiverManager {
        return CaregiverManager(caregivers: [Caregiver.mockPending, Caregiver.mockAccepted], api: TAPI.mock)
    }

    static var mockNoCaregivers: CaregiverManager {
        return CaregiverManager(caregivers: [], api: TAPI.mock)
    }
}
