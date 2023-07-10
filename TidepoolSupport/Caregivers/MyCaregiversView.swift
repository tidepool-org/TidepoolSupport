//
//  MyCaregiversView.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/8/23.
//

import SwiftUI
import LoopKitUI
import TidepoolKit

struct MyCaregiversView: View {
    @EnvironmentObject private var displayGlucosePreference: DisplayGlucosePreference
    
    @Environment(\.appName) private var appName
    @Environment(\.guidanceColors) private var guidanceColors
    
    @ObservedObject var caregiverManager: CaregiverManager
    
    @State private var isCreatingInvitation: Bool = false
    @State private var selectedCaregiver: Caregiver?
    @State private var showingCaregiverActions: Bool = false
    @State private var showingRemoveConfirmation: Bool = false
    @State private var showingResendConfirmation: Bool = false
    @State private var showingResendSuccess: Bool = false
    @State private var showingRemoveSuccess: Bool = false
    @State private var showingTroubleDialog: Bool = false
    @State private var troubleTitle: String = ""
    
    let primaryButton = SetupButton(type: .custom)
    
    var body: some View {
        List {
            Section(header: header)
            {
                ForEach(caregiverManager.caregivers) { caregiver in
                    Button {
                        selectedCaregiver = caregiver
                        showingCaregiverActions = true
                    } label: {
                        HStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(caregiver.name).fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text(caregiver.email).font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if caregiverManager.caregiversPendingRemoval.contains(caregiver) {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .frame(width: 26, height: 26)
                            } else {
                                switch caregiver.status {
                                case InvitationStatus.pending:
                                    Text("Invite Sent").font(.caption).foregroundColor(.accentColor).padding(2).padding(.horizontal, 2).background(Color.accentColor.opacity(0.3).cornerRadius(2))
                                case InvitationStatus.resent:
                                    Text("Invite Sent").font(.caption).foregroundColor(.accentColor).padding(2).padding(.horizontal, 2).background(Color.accentColor.opacity(0.3).cornerRadius(2))
                                case InvitationStatus.declined:
                                    Text("Invite Declined").font(.caption).foregroundColor(guidanceColors.critical).padding(2).padding(.horizontal, 2).background(guidanceColors.critical.opacity(0.3).cornerRadius(2))
                                default:
                                    EmptyView()
                                }
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                    .confirmationDialog(selectedCaregiver?.name ?? "", isPresented: $showingCaregiverActions, titleVisibility: .hidden) {
                        if selectedCaregiver?.status == .pending {
                            Button(LocalizedString("Resend Invitation", comment: "Button title for caregiver resend invite action")) {
                                showingResendConfirmation = true
                            }
                        }
                        Button(LocalizedString("Remove Caregiver", comment: "Button title for remove caregiver action"), role: .destructive) {
                            showingRemoveConfirmation = true
                        }
                    }
                    .alert(LocalizedString("Remove Caregiver?", comment: "Alert title for remove caregiver confirmation."),
                           isPresented: $showingRemoveConfirmation,
                           presenting: selectedCaregiver,
                           actions: { caregiver in
                        Button(role: .destructive) {
                            Task {
                                await caregiverManager.removeCaregiver(caregiver: caregiver)
                                if caregiverManager.removeError {
                                    troubleTitle = "Remove Error"
                                    showingTroubleDialog = true
                                } else {
                                    showingRemoveSuccess = true
                                }
                            }
                        } label: {
                            Text(LocalizedString("Remove", comment: "Button title on alert for remove caregiver confirmation"))
                        }
                    },
                           message: { caregiver in
                        Text(String(format: LocalizedString("%1$@ will lose all access to your data. Are you sure you want to remove this caregiver?", comment: "Format string for message on remove caregiver alert confirmation"), caregiver.name))
                    })
                    .alert(LocalizedString("Resend Invitation", comment: "Alert title for resend invitation confirmation."),
                           isPresented: $showingResendConfirmation,
                           presenting: selectedCaregiver,
                           actions: { caregiver in
                        Button(role: .destructive) {
                            Task {
                                await caregiverManager.resendInvite(caregiver: caregiver)
                                if caregiverManager.resendError {
                                    troubleTitle = "Resend Error"
                                    showingTroubleDialog = true
                                } else {
                                    caregiverManager.resentInviteFlagStorage.set(true, forKey: caregiver.id)
                                    await caregiverManager.fetchCaregivers()
                                    showingResendSuccess = true
                                }
                            }
                        } label: {
                            Text(LocalizedString("Resend Invite", comment: "Button title on alert for resend invitation confirmation"))
                        }
                    },
                           message: { caregiver in
                        Text(String(format: LocalizedString("Are you sure you want to resend a share invitation to %1$@ ?", comment: "Format string for message on resend invitation alert confirmation"), caregiver.name))
                    })
                    .alert(troubleTitle,
                           isPresented: $showingTroubleDialog,
                           actions: {
                        Button(role: .cancel) {
                            if caregiverManager.removeError {
                                caregiverManager.removeError = false
                            } else {
                                caregiverManager.resendError = false
                            }
                            showingTroubleDialog = false
                        } label: {
                            Text(LocalizedString("OK", comment: "Button title for trouble alert"))
                        }
                    },
                           message: {
                        Text("We weren’t able to complete this action. Please try again.")
                    })
                }
                NavigationLink(
                    destination: NewCaregiverView(api: caregiverManager.api, isCreatingInvitation: $isCreatingInvitation),
                    isActive: $isCreatingInvitation,
                    label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(LocalizedString("Invite a new caregiver", comment: "Navigation link title to invite a new caregiver"))
                        }
                        .foregroundColor(.accentColor)
                    })
                .isDetailLink(false)
            }
        }
        // TODO: Need to block user access to other Caregivers during remove/resendSuccessTray.
        VStack(spacing: 0) {
            if showingRemoveSuccess {
                removeSuccessTray
            } else if showingResendSuccess {
                resendSuccessTray
            } else {
                EmptyView()
            }
        }
        .task {
            await caregiverManager.fetchCaregivers()
        }
        .navigationTitle(LocalizedString("My Caregivers", comment: "Navigation title for My Caregivers page"))
        .navigationBarTitleDisplayMode(.large)
    }
    
    var header: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(String(format: LocalizedString("These people can view your %1$@ activity.", comment: "Format string for section header on My Caregivers page"), appName))
                .textCase(nil)
                .font(.body.weight(.semibold))
                .foregroundColor(.primary)
            if caregiverManager.caregivers.count == 0 {
                VStack {
                    Text(LocalizedString("You haven’t added any caregivers yet!", comment: "Informative text shown on My Caregivers page when no caregiver invitations or followers exist"))
                        .textCase(nil)
                        .font(.body.italic())
                        .padding(.top, 20)
                }.frame(maxWidth: .infinity)
            } else {
                Divider()
                    .overlay(.primary)
            }
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 18, trailing: 0))
    }
    
    var removeSuccessTray: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(Font.system(.largeTitle))
                Text(LocalizedString("Access Removed", comment: "Success message for caregiver removal"))
                    .bold()
            }
            Button {
                showingRemoveSuccess = false
            } label: {
                Text(LocalizedString("Done", comment: "Button title to continue"))
            }
            .actionButtonStyle(.primary)
            .textCase(nil)
            .padding()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground).shadow(radius: 5))
        
    }
    
    var resendSuccessTray: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(Font.system(.largeTitle))
                Text(LocalizedString("Invite Resent", comment: "Success message for caregiver resend"))
                    .bold()
            }
            Button {
                showingResendSuccess = false
            } label: {
                    Text(LocalizedString("Done", comment: "Button title to continue"))
            }
            .actionButtonStyle(.primary)
            .textCase(nil)
            .padding()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground).shadow(radius: 5))
    }
}

struct MyCaregiversView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyCaregiversView(caregiverManager: CaregiverManager(api: .mock))
        }
        .environment(\.appName, "Tidepool Loop")
    }
}
