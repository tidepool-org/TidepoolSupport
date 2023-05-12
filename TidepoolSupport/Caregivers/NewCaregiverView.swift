//
//  NewCaregiver.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/8/23.
//

import SwiftUI

struct NewCaregiverView: View {
    @Environment(\.appName) private var appName

    @ObservedObject var viewModel: InvitationViewModel
    @State private var formComplete: Bool = false
    @Binding var isCreatingInvitation: Bool

    var body: some View {
        Form {
            Section(header: header)
            {
                TextField(text: $viewModel.nickname) {
                    Text("Nickname")
                }
                .textInputAutocapitalization(.words)
                .onChange(of: viewModel.nickname) { newValue in
                    validateInputs()
                }

                TextField(text: $viewModel.email) {
                    Text("Email")
                }
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .onChange(of: viewModel.email) { newValue in
                    validateInputs()
                }
            }
        }
        .onAppear {
            validateInputs()
        }
        .navigationTitle("Invite Caregiver")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AlertConfigurationView(viewModel: viewModel, isCreatingInvitation: $isCreatingInvitation)
                } label: {
                    Text("Next")
                }
                .isDetailLink(false)
                .disabled(!formComplete)
            }
        }
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(String(format: LocalizedString("To share your %1$@ activity with a new caregiver, enter their name and email address. Then tap Next to configure their alerts and alarms.", comment: "Format string for section header on New Caregiver page"), appName))
                .textCase(nil)
                .font(.body)
            Divider()
                .overlay(.primary)
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 18, trailing: 0))
    }

    func validateInputs() {
        formComplete = viewModel.nickname.count >= 2 && viewModel.isEmailValid
    }

}

struct NewCaregiver_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewCaregiverView(viewModel: InvitationViewModel.mock, isCreatingInvitation: .constant(true))
        }
        .environment(\.appName, "Tidepool Loop")

    }
}
