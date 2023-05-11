//
//  MyCaregiversView.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/8/23.
//

import SwiftUI

struct MyCaregiversView: View {

    @Environment(\.appName) private var appName

    @ObservedObject var caregiverManager: CaregiverManager

    @State private var selectedCaregiver: Caregiver?
    @State private var showingCaregiverOptions: Bool = false
    @State private var showingRemoveConfirmation: Bool = false

    var body: some View {
        List {
            Section(header: header)
            {
                ForEach(caregiverManager.caregivers) { caregiver in
                    Button {
                        selectedCaregiver = caregiver
                        showingCaregiverOptions = true
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
                    .confirmationDialog(selectedCaregiver?.name ?? "Unselected", isPresented: $showingCaregiverOptions, titleVisibility: .visible) {
                        Button("Resend Invitation") {
                            print("here1")
                        }

                        Button("Remove Caregiver", role: .destructive) {
                            showingRemoveConfirmation = true
                        }
                    }
                    .alert("Remove Caregiver?",
                           isPresented: $showingRemoveConfirmation,
                           presenting: caregiver,
                           actions: { caregiver in
                               Button(role: .destructive) {
                                   // Handle the deletion.

                               } label: {
                                   Text("Remove")
                               }
                           },
                           message: { caregiver in
                              Text(String(format: LocalizedString("%1$@ will lose all access to your data. Are you sure you want to remove this caregiver?", comment: "Format string for message on remove caregiver alert confirmation"), caregiver.name))
                           })

                }
                NavigationLink {
                    NewCaregiverView(viewModel: InvitationViewModel())
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Invite a new caregiver")
                    }
                    .foregroundColor(.accentColor)
                }
            }
        }
        .navigationTitle("My Caregivers")
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
                    Text("You haven’t added any caregivers yet!")
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
