//
//  NewCaregiver.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/8/23.
//

import SwiftUI
import TidepoolKit

struct NewCaregiverView: View {
    @Environment(\.appName) private var appName
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel: InvitationViewModel
    @State private var formComplete: Bool = false
    @State private var showCancelConfirmationAlert: Bool = false
    @Binding var isCreatingInvitation: Bool

    enum FocusedField {
        case nickname, email
    }
    @FocusState private var focusedField: FocusedField?

    init(caregiverManager: CaregiverManager, isCreatingInvitation: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: InvitationViewModel(caregiverManager: caregiverManager))
        self._isCreatingInvitation = isCreatingInvitation
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section(header: header)
                {
                    TextField(text: $viewModel.nickname) {
                        Text(LocalizedString("Caregiver Nickname", comment: "Placeholder text for caregiver nickname field of invite caregiver form"))
                    }
                    .showRequiredLabel(true)
                    .focused($focusedField, equals: .nickname)
                    .textInputAutocapitalization(.words)
                    .onChange(of: viewModel.nickname) { newValue in
                        validateInputs()
                    }
                    
                    TextField(text: $viewModel.email) {
                        Text(LocalizedString("Email", comment: "Placeholder text for email field of invite caregiver form"))
                    }
                    .showRequiredLabel(true)
                    .focused($focusedField, equals: .email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.email) { newValue in
                        validateInputs()
                    }
                }
            }
            
            continueTray
        }
        .onAppear {
            validateInputs()
            focusedField = .nickname
        }
        .navigationTitle(LocalizedString("Invite a New Caregiver", comment: "Navigation title for first page of invite caregiver form"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCancelConfirmationAlert = true
                } label: {
                    Text("Cancel")
                }

            }
        }
        .interactiveDismissDisabled()
        .alert(Text("Close Invitation?"), isPresented: $showCancelConfirmationAlert) {
            Button("Cancel", role: .cancel, action: {})
            
            Button("Close Invite") {
                dismiss()
            }
        } message: {
            Text("If you leave now, you will need to create this invitation again.")
        }
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(String(format: LocalizedString("To share your %1$@ activity with a new caregiver, enter their name and email address. Then tap Continue to setup their alerts and alarms.", comment: "Format string for section header on New Caregiver page"), appName))
                .textCase(nil)
                .font(.body.weight(.semibold))
                .foregroundColor(.primary)
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 18, trailing: 0))
    }

    func validateInputs() {
        formComplete = viewModel.nickname.count >= 2 && viewModel.isEmailValid
    }
    
    var continueTray: some View {
        NavigationLink {
            AlertConfigurationView(viewModel: viewModel, isCreatingInvitation: $isCreatingInvitation)
        } label: {
            Text(LocalizedString("Continue", comment: "Button title to continue to next page of invite caregiver form"))
        }
        .buttonStyle(ActionButtonStyle())
        .padding()
        .textCase(nil)
        .background(Color(UIColor.secondarySystemGroupedBackground).edgesIgnoringSafeArea(.bottom).shadow(radius: 5))
    }

}

extension View {
    @ViewBuilder
    func showRequiredLabel(_ show: Bool) -> some View {
        if show {
            self
                .overlay(alignment: .trailing) {
                    Text("Required")
                        .foregroundStyle(Color.secondary)
                }
        } else {
            self
        }
    }
}

struct NewCaregiver_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewCaregiverView(caregiverManager: CaregiverManager(api: .mock), isCreatingInvitation: .constant(true))
        }
        .environment(\.appName, "Tidepool Loop")

    }
}
