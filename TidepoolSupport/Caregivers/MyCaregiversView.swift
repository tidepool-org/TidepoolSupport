//
//  MyCaregiversView.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/8/23.
//

import SwiftUI
import LoopKitUI

struct MyCaregiversView: View {
    @EnvironmentObject private var displayGlucosePreference: DisplayGlucosePreference

    @Environment(\.appName) private var appName

    @ObservedObject var caregiverManager: CaregiverManager

    @State private var selectedCaregiver: Caregiver?
    @State private var showingCaregiverActions: Bool = false
    @State private var showingRemoveConfirmation: Bool = false
    @State private var isCreatingInvitation: Bool = false

    var body: some View {
        List {
            Section(header: header)
            {
                ForEach(caregiverManager.caregivers) { caregiver in
                    Button {
                        selectedCaregiver = caregiver
                        showingCaregiverActions = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(caregiver.name)
                                    .foregroundColor(.primary)
                                Text(caregiver.email)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "person.fill")
                                .foregroundColor(.primary)
                        }
                    }
                    .confirmationDialog(selectedCaregiver!.name, isPresented: $showingCaregiverActions, titleVisibility: .visible) {
                        Button(LocalizedString("Resend Invitation", comment: "Button title for caregiver resend invite action")) {
                            // TODO
                        }

                        Button(LocalizedString("Remove Caregiver", comment: "Button title for remove caregiver action"), role: .destructive) {
                            showingRemoveConfirmation = true
                        }
                    }
                        .alert(LocalizedString("Remove Caregiver?", comment: "Alert title for remove caregiver confirmation."),
                           isPresented: $showingRemoveConfirmation,
                           presenting: caregiver,
                           actions: { caregiver in
                        Button(role: .destructive) {
                            // TODO - handle the deletion
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
        .onAppear {
            // TODO: refresh invites and followers from backend
        }
        .navigationTitle(LocalizedString("My Caregivers", comment: "Navigation title for My Caregivers page"))
        .navigationBarTitleDisplayMode(.large)
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(String(format: LocalizedString("These people can view your %1$@ activity.", comment: "Format string for section header on My Caregivers page"), appName))
                .textCase(nil)
                .font(.body.bold())
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
            MyCaregiversView(caregiverManager: CaregiverManager.mock)
        }
        .environment(\.appName, "Tidepool Loop")
    }
}
