//
//  CaregiverManager.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/11/23.
//

import Foundation
import TidepoolKit
import os.log

class CaregiverManager: ObservableObject {
    
    private static let caregiverManagerIdentifier = "CaregiverManager"
    private let log = OSLog(category: caregiverManagerIdentifier)
    
    private let userDefaultsSave = UserDefaults.standard
    private let backendInvitesToIgnore = ["bigdata@tidepool.org", "bigdata+CWD@tidepool.org"]
    
    var api: TAPI
    
    init(api: TAPI) {
        self.api = api
    }
    
    @MainActor
    func fetchCaregivers() async -> [Caregiver] {
        var caregivers = [Caregiver]()
        
        await processExistingTrusteeUsers(caregivers: &caregivers)
        await processPendingInvites(caregivers: &caregivers)
        
        return caregivers
    }
    
    func removeCaregiver(caregiverEmail: String) async {
        do {
            // TODO: cancelInvite only removes pending invites, need to add logic here to remove caregivers with sharing status.
            let response = try await api.cancelInvite(invitedByEmail: caregiverEmail)
        } catch {
            log.error("removeCaregiver error: %{public}@",error.localizedDescription)
        }
    }
    
    private func processExistingTrusteeUsers(caregivers: inout [Caregiver]) async {
        do {
            let trusteeUsers = try await api.getUsers()
            
            trusteeUsers.forEach { user in
                let email = user.emails.first
                let status = InvitationStatus.accepted
                let id = user.userid
                var fullName = ""
                
                var nickName = userDefaultsSave.string(forKey: user.emails.first ?? "")
                if user.profile != nil {
                    fullName = user.profile?.fullName ?? ""
                }
                
                /// Default to profile full name if no nickname exists
                if (nickName == nil) {
                    nickName = fullName
                }
                
                caregivers.append(Caregiver(name: nickName ?? "", email: email ?? "", status: status, id: id))
            }
        } catch {
            log.error("processExistingTrusteeUsers error: %{public}@",error.localizedDescription)
        }
        
    }
    
    private func processPendingInvites(caregivers: inout [Caregiver]) async {
        do {
            let pendingInvites = try await api.getPendingInvites()
            pendingInvites.forEach { invitee in
                let email = invitee.email
                if backendInvitesToIgnore.contains(email){return}
                let nickName = userDefaultsSave.string(forKey: invitee.email) ?? ""
                let status: InvitationStatus
                
                switch invitee.status {
                    /// Currently a user must create a web account before the 'ignore' option is offered resulting in a declined status.
                    /// In this use-case, the invitee will have a full name, however,
                    /// this is not currently updated as this UX may be refactored to redirect to the mobile app.
                case "declined":
                    status = InvitationStatus.declined
                default:
                    status = InvitationStatus.pending
                }
                
                /// In the 'pending' use-case, invitee does not yet have an account,
                /// therefore, does not have a userId, unique invitation key is a placeholder for now.
                caregivers.append(Caregiver(name: nickName, email: email, status: status, id: invitee.key))
            }
        } catch {
            log.error("processPendingInvites error: %{public}@",error.localizedDescription)
        }
    }
}


// MARK: - Mocks
extension TAPI {
    static var mock: TAPI {
        TAPI(clientId: "mock", redirectURL: URL(string: "https://mock.com/mock")!)
    }
}
