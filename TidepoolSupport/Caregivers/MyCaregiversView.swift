//
//  MyCaregiversView.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/8/23.
//

import SwiftUI
import LoopKitUI

@MainActor
class MyCaregiversViewModel: ObservableObject {
    @Published var caregivers: [Caregiver]
    
    @Published var selectedCaregiver: Caregiver?
    @Published var showingCaregiverActions: Bool = false
    @Published var showingRemoveConfirmation: Bool = false
    @Published var isCreatingInvitation: Bool = false
    
    let caregiverManager: CaregiverManager
    
    init(caregiverManager: CaregiverManager, caregivers: [Caregiver] = []) {
        self.caregiverManager = caregiverManager
        self.caregivers = caregivers
    }
    
    func fetchCaregivers() async {
        self.caregivers = await caregiverManager.fetchCaregivers()
    }
}

struct MyCaregiversView: View {
    @EnvironmentObject private var displayGlucosePreference: DisplayGlucosePreference

    @Environment(\.appName) private var appName
    
    @StateObject var viewModel: MyCaregiversViewModel
    
    init(caregiverManager: CaregiverManager) {
        self._viewModel = .init(wrappedValue: MyCaregiversViewModel(caregiverManager: caregiverManager))
    }

    var body: some View {
        List {
            Section(header: header)
            {
                ForEach(viewModel.caregivers) { caregiver in
                    Button {
                        viewModel.selectedCaregiver = caregiver
                        viewModel.showingCaregiverActions = true
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
                    .confirmationDialog(viewModel.selectedCaregiver?.name ?? "", isPresented: $viewModel.showingCaregiverActions, titleVisibility: .visible) {
                        Button(LocalizedString("Resend Invitation", comment: "Button title for caregiver resend invite action")) {
                            // TODO
                        }

                        Button(LocalizedString("Remove Caregiver", comment: "Button title for remove caregiver action"), role: .destructive) {
                            viewModel.showingRemoveConfirmation = true
                        }
                    }
                        .alert(LocalizedString("Remove Caregiver?", comment: "Alert title for remove caregiver confirmation."),
                               isPresented: $viewModel.showingRemoveConfirmation,
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
                    destination: NewCaregiverView(viewModel: InvitationViewModel(api: viewModel.caregiverManager.api), isCreatingInvitation: $viewModel.isCreatingInvitation),
                    isActive: $viewModel.isCreatingInvitation,
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
            await viewModel.fetchCaregivers()
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
            if viewModel.caregivers.count == 0 {
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
