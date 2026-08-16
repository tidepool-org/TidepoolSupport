//
//  NewCaregiver.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/8/23.
//

import SwiftUI
import UIKit
import LoopKitUI
import TidepoolKit

struct NewCaregiverView: View {
    @Environment(\.appName) private var appName
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel: InvitationViewModel
    @State private var showCancelConfirmationAlert: Bool = false
    @Binding var isCreatingInvitation: Bool

    private var formComplete: Bool {
        viewModel.nickname.count >= 2 && viewModel.isEmailValid
    }

    enum FocusedField {
        case nickname, email, fullName
    }
    
    @FocusState private var focusedField: FocusedField?
    @State private var hasAutoFocused = false
    @State private var showAlertConfiguration = false

    init(caregiverManager: CaregiverManager, isCreatingInvitation: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: InvitationViewModel(caregiverManager: caregiverManager))
        self._isCreatingInvitation = isCreatingInvitation
    }

    var body: some View {
        Form {
            Section(header: header, footer: footer)
            {
                TextField(text: $viewModel.nickname) {
                    Text(LocalizedString("Caregiver Nickname", comment: "Placeholder text for caregiver nickname field of invite caregiver form"))
                }
                .focused($focusedField, equals: .nickname)
                .textContentType(.name)

                TextField(text: $viewModel.email) {
                    Text(LocalizedString("Email", comment: "Placeholder text for email field of invite caregiver form"))
                }
                .focused($focusedField, equals: .email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }
        }
        .background(
            NavigationLink(isActive: $showAlertConfiguration) {
                AlertConfigurationView(viewModel: viewModel, isCreatingInvitation: $isCreatingInvitation)
            } label: {
                EmptyView()
            }
            .opacity(0)
            .accessibility(hidden: true)
        )
        .actionAreaInset {
            continueAction
        }
        .keyboardEntryPage()
        .onAppear {
            guard !hasAutoFocused, viewModel.nickname.isEmpty else { return }
            hasAutoFocused = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = viewModel.caregiverManager.profile == nil ? .fullName : .nickname
            }
        }
        .onDisappear {
            focusedField = nil
        }
        .navigationTitle(LocalizedString("Invite a Caregiver", comment: "Navigation title for first page of invite caregiver form"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showCancelConfirmationAlert = true
                } label: {
                    Text("Cancel")
                }

            }
        }
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
        Text(String(format: LocalizedString("To share your %1$@ activity with a new caregiver, enter their name and email address. Then tap Continue to set up their alerts and alarms.", comment: "Format string for section header on New Caregiver page"), appName))
            .textCase(nil)
            .font(.body)
            .foregroundColor(.primary)
            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 18, trailing: 0))
    }
    
    var footer: some View {
        Text("Both fields are required for a new invite.")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var continueAction: some View {
        Button(action: {
            focusedField = nil
            KeyboardDismissal.resignFirstResponder()
            showAlertConfiguration = true
        }) {
            Text(LocalizedString("Continue", comment: "Button title to continue to next page of invite caregiver form"))
        }
        .disabled(!formComplete)
        .animation(.default, value: formComplete)
        .buttonStyle(LoopKitUI.ActionButtonStyle())
        .textCase(nil)
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
