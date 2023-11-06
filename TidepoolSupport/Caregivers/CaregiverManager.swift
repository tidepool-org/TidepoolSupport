//
//  CaregiverManager.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/11/23.
//

import Foundation
import TidepoolKit
import os.log

@MainActor
class CaregiverManager: ObservableObject {
    
    enum ErrorType: Error {
        case resendInvite
        case removeCaregiver
        case createInvite
        
        var title: String {
            switch self {
            case .resendInvite: return "Resend Error"
            case .removeCaregiver: return "Remove Error"
            case .createInvite: return "Invite Error"
            }
        }
        
        var description: String {
            switch self {
            case .resendInvite: return LocalizedString("Error resending invite.", comment: "Resend invite error")
            case .removeCaregiver: return LocalizedString("Error removing caregiver.", comment: "Remove caregiver error")
            case .createInvite: return LocalizedString("Error inviting caregiver.", comment: "Invite caregiver error")
            }
        }
    }
    
    @Published var caregivers: [Caregiver] = []
    @Published var caregiversPendingRemoval: [Caregiver] = []
    @Published var profile: TProfile? = nil
    @Published var errorType: ErrorType? = nil
    
    private static let caregiverManagerIdentifier = "CaregiverManager"
    private let log = OSLog(category: caregiverManagerIdentifier)
    
    private let backendInvitesToIgnore = ["bigdata@tidepool.org", "bigdata+CWD@tidepool.org"]
    
    var api: TAPI?
    
    init(api: TAPI?) {
        self.api = api
    }
    
    func inviteCaregiver(email: String, nickname: String?, permissions: TPermissions) async throws -> TInvite {
        guard let api else {
            throw ErrorType.createInvite
        }
        
        return try await api.sendInvite(request: TInviteRequest(email: email, nickname: nickname, permissions: permissions))
    }
    
    func fetchAllCaregivers() async {
        let current = await fetchCurrentCaregivers()
        let pending = await fetchPendingInvites()
        
        if caregivers != current + pending {
            caregivers = current + pending
        }
        
        profile = try? await api?.getProfile()
    }
    
    private func fetchCurrentCaregivers() async -> [Caregiver] {
        do {
            let trusteeUsers = try await api?.getUsers() ?? []
            
            return trusteeUsers.compactMap { user in
                guard let email = user.emails.first, !backendInvitesToIgnore.contains(email) else {
                    return nil
                }
                let status = InvitationStatus.accepted
                let id = user.userid
                let name = user.profile?.fullName
                
                return Caregiver(name: name ?? "", email: email, status: status, id: id)
            }
        } catch {
            log.error("fetchExistingTrusteeUsers error: %{public}@",error.localizedDescription)
            return []
        }
    }
    
    private func fetchPendingInvites() async -> [Caregiver] {
        do {
            let pendingInvites = try await api?.getPendingInvitesSent().sorted(by: { $0.created < $1.created }) ?? []
            return pendingInvites.compactMap { invitee in
                let email = invitee.email
                let status = InvitationStatus(rawValue: invitee.status) ?? .pending
                
                guard !backendInvitesToIgnore.contains(email) else {
                    return nil
                }
                
                let newCaregiver = Caregiver(
                    name: invitee.context?.nickname ?? "",
                    email: email,
                    status: status,
                    id: invitee.key
                )
                
                return newCaregiver
            }
        } catch {
            log.error("fetchPendingInvites error: %{public}@",error.localizedDescription)
            return []
        }
    }
    
    func resendInvite(caregiver: Caregiver) async {
        do {
            let inviteKey = caregiver.id
            let _ = try await api?.resendInvite(key: inviteKey)
            guard let (index, caregiver) = caregivers.enumerated().first(where: { $0.element.id == caregiver.id }) else {
                return
            }
            let newCaregiver = caregiver.updateStatus(status: .resent)
            caregivers.remove(at: index)
            caregivers.insert(newCaregiver, at: index)
        } catch {
            errorType = .resendInvite
            log.error("resendInvite error: %{public}@",error.localizedDescription)
        }
    }
    
    private func removeCaregiverPermissions(caregiver: Caregiver) async {
        do {
            let permissions = TPermissions.init()
            let _ = try await api?.grantPermissionsInGroup(userId: caregiver.id, permissions: permissions)
        } catch {
            errorType = .removeCaregiver
            log.error("removeCaregiverPermissions error: %{public}@",error.localizedDescription)
        }
    }
    
    private func removeInvitation(caregiverEmail: String) async {
        do {
            let _ = try await api?.cancelInvite(invitedByEmail: caregiverEmail)
        } catch {
            errorType = .removeCaregiver
            log.error("removeInvitation error: %{public}@",error.localizedDescription)
        }
    }
        
    func removeCaregiver(caregiver: Caregiver) async {
        caregiversPendingRemoval.append(caregiver)
        
        if let caregiverIndexToRemove = caregivers.firstIndex(of: caregiver) {
            if caregiver.status == InvitationStatus.accepted {
                await removeCaregiverPermissions(caregiver: caregiver)
            } else { /// Caregiver has pending or declined invitation status
                let caregiverEmailToRemove = caregivers[caregiverIndexToRemove].email
                await removeInvitation(caregiverEmail: caregiverEmailToRemove)
            }
            caregivers.remove(at: caregiverIndexToRemove)
        }
        if let caregiverIndexToRemove = caregiversPendingRemoval.firstIndex(of: caregiver) {
            caregiversPendingRemoval.remove(at: caregiverIndexToRemove)
        }
    }
}


// MARK: - Mocks
extension TAPI {
    static var mock: TAPI {
        TAPI(clientId: "mock", redirectURL: URL(string: "https://mock.com/mock")!)
    }
}
