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
    
    let primaryButton = SetupButton(type: .custom)
    
    
    var body: some View {
        List {
            Section(header: header)
            {
                ForEach(caregiverManager.caregivers) { caregiver in
                    Button {
                        caregiverManager.selectedCaregiver = caregiver
                        caregiverManager.showingCaregiverActions = true
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
                    .confirmationDialog(caregiverManager.selectedCaregiver?.name ?? "", isPresented: $caregiverManager.showingCaregiverActions, titleVisibility: .visible) {
                        if caregiverManager.selectedCaregiver?.status == .declined {
                            Button(LocalizedString("Resend Invitation", comment: "Button title for caregiver resend invite action")) {
                                // TODO: Logic needed here. Need to discuss TPermissions resurrection from original invite.
                            }
                        }
                        Button(LocalizedString("Remove Caregiver", comment: "Button title for remove caregiver action"), role: .destructive) {
                            caregiverManager.showingRemoveConfirmation = true
                        }
                        
                    }
                    .alert(LocalizedString("Remove Caregiver?", comment: "Alert title for remove caregiver confirmation."),
                           isPresented: $caregiverManager.showingRemoveConfirmation,
                           presenting: caregiverManager.selectedCaregiver,
                           actions: { caregiver in
                        Button(role: .destructive) {
                            Task {
                                await caregiverManager.removeCaregiver(caregiver: caregiver)
                            }
                        } label: {
                            Text(LocalizedString("Remove", comment: "Button title on alert for remove caregiver confirmation"))
                        }
                    },
                           message: { caregiver in
                        Text(String(format: LocalizedString("%1$@ will lose all access to your data. Are you sure you want to remove this caregiver?", comment: "Format string for message on remove caregiver alert confirmation"), caregiver.name))
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
        .task {
            await caregiverManager.fetchCaregivers()
        }
        .navigationTitle(LocalizedString("My Caregivers", comment: "Navigation title for My Caregivers page"))
        .navigationBarTitleDisplayMode(.large)
//        VStack(spacing: 0) {
//            if (viewModel.selectedCaregiver?.status == .declined) {
//                Button(LocalizedString("Resend Invitation", comment: "Button title for caregiver resend invite action")) {
//                    // TODO
//                }
//                Button(LocalizedString("Remove Caregiver", comment: "Button title for remove caregiver action"), role: .destructive) {
//                    viewModel.showingRemoveConfirmation = true
//                }
//            } else {
//                Button(LocalizedString("Remove Caregiver", comment: "Button title for remove caregiver action"), role: .destructive) {
//                    viewModel.showingRemoveConfirmation = true
//                }
//            }
//        }.padding(.bottom).background(Color(.secondarySystemGroupedBackground).shadow(radius: 5))
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
}

struct MyCaregiversView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyCaregiversView(caregiverManager: CaregiverManager(api: .mock))
        }
        .environment(\.appName, "Tidepool Loop")
    }
}
