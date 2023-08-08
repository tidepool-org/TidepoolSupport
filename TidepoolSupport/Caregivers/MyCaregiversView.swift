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
    
    enum Alert {
        case showingRemoveConfirmation
        case showingResendConfirmation
        case showingTroubleDialog
    }
    
    enum BottomTray {
        case showingResendSuccess
        case showingRemoveSuccess
        case showingCaregiverActions
    }
    
    @State var presentedAlert: Alert? = nil
    @State var presentedBottomTray: BottomTray? = nil
    
    let primaryButton = SetupButton(type: .custom)
    
    var body: some View {
        List {
            Section(header: header)
            {
                ForEach(caregiverManager.caregivers) { caregiver in
                    Button {
                        selectedCaregiver = caregiver
                        presentedBottomTray = .showingCaregiverActions
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
                                    Text("Invite Resent").font(.caption).foregroundColor(.accentColor).padding(2).padding(.horizontal, 2).background(Color.accentColor.opacity(0.3).cornerRadius(2))
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
                    .alert(LocalizedString("Remove Caregiver?", comment: "Alert title for remove caregiver confirmation."),
                           isPresented: Binding(get: {
                        presentedAlert == .showingRemoveConfirmation
                    }, set: { _ in
                        presentedAlert = nil
                    }),
                           presenting: selectedCaregiver,
                           actions: { caregiver in
                        Button(role: .destructive) {
                            Task {
                                await caregiverManager.removeCaregiver(caregiver: caregiver)
                                if (caregiverManager.errorType != nil) {
                                    presentedAlert = .showingTroubleDialog
                                } else {
                                    presentedAlert = nil
                                    presentedBottomTray = .showingRemoveSuccess
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
                           isPresented: Binding(get: {
                        presentedAlert == .showingResendConfirmation
                    }, set: { _ in
                        presentedAlert = nil
                    }),
                           presenting: selectedCaregiver,
                           actions: { caregiver in
                        Button(role: .destructive) {
                            Task {
                                await caregiverManager.resendInvite(caregiver: caregiver)
                                if (caregiverManager.errorType != nil) {
                                    presentedAlert = .showingTroubleDialog
                                } else {
                                    caregiverManager.resentInviteFlagStorage.set(true, forKey: caregiver.id)
                                    await caregiverManager.fetchCaregivers()
                                    presentedAlert = nil
                                    presentedBottomTray = .showingResendSuccess
                                }
                            }
                        } label: {
                            Text(LocalizedString("Resend Invite", comment: "Button title on alert for resend invitation confirmation"))
                        }
                    },
                           message: { caregiver in
                        Text(String(format: LocalizedString("Are you sure you want to resend a share invitation to %1$@ ?", comment: "Format string for message on resend invitation alert confirmation"), caregiver.name))
                    })
                    .alert(caregiverManager.errorType?.title ?? "Error",
                           isPresented: Binding(get: {
                        presentedAlert == .showingTroubleDialog
                    }, set: { _ in
                        presentedAlert = nil
                    }),
                           actions: {
                        Button(role: .cancel) {
                            caregiverManager.errorType = nil
                            presentedAlert = nil
                        } label: {
                            Text(LocalizedString("OK", comment: "Button title for trouble alert"))
                        }
                    },
                           message: {
                        Text(String(format: LocalizedString("%1$@ Please try again.", comment: "Format string for message error alert"), caregiverManager.errorType?.description ?? "We weren’t able to complete this action."))
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
        }.disabled(presentedBottomTray == .showingRemoveSuccess || presentedBottomTray == .showingResendSuccess || presentedBottomTray == .showingCaregiverActions)
        VStack(spacing: 0) {
            if presentedBottomTray == .showingRemoveSuccess {
                removeSuccessTray
            } else if presentedBottomTray == .showingResendSuccess {
                resendSuccessTray
            } else if presentedBottomTray == .showingCaregiverActions {
                caregiverActionsTray
            }
        }.animation(.default, value: presentedAlert).transition(.move(edge: .bottom))
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
            }
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 18, trailing: 0))
    }
    
    var caregiverActionsTray: some View {
        VStack(spacing: 12) {
            Text(String(format: LocalizedString("%1$@", comment: "Format string for displaying selected caregiver's name."), selectedCaregiver?.name ?? "")).font(.title2).fontWeight(.semibold)
            if selectedCaregiver?.status == .pending {
                Button {
                    presentedBottomTray = nil
                    presentedAlert = .showingResendConfirmation
                } label: {
                    Text(LocalizedString("Resend Invitation", comment: "Button title for caregiver resend invite action"))
                }
                .actionButtonStyle(.primary)
                .textCase(nil)
            }
            Button {
                presentedBottomTray = nil
                presentedAlert = .showingRemoveConfirmation
            } label: {
                Text(LocalizedString("Remove Caregiver", comment: "Button title for remove caregiver action"))
            }
            .actionButtonStyle(.destructive)
            .textCase(nil)
            Button {
                presentedBottomTray = nil
            } label: {
                Text(LocalizedString("Cancel", comment: "Button title to cancel"))
            }
            .actionButtonStyle(.secondary)
            .textCase(nil)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground).edgesIgnoringSafeArea(.bottom).shadow(radius: 5))
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
                presentedBottomTray = nil
            } label: {
                Text(LocalizedString("Done", comment: "Button title to continue"))
            }
            .actionButtonStyle(.primary)
            .textCase(nil)
            .padding()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground).edgesIgnoringSafeArea(.bottom).shadow(radius: 5))
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
                presentedBottomTray = nil
            } label: {
                Text(LocalizedString("Done", comment: "Button title to continue"))
            }
            .actionButtonStyle(.primary)
            .textCase(nil)
            .padding()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground).edgesIgnoringSafeArea(.bottom).shadow(radius: 5))
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
