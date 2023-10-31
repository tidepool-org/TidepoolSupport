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
    @State private var showCancelConfirmationAlert: Bool = false
    @Binding var isCreatingInvitation: Bool

    private var formComplete: Bool {
        viewModel.nickname.count >= 2 && viewModel.isEmailValid && (viewModel.caregiverManager.profile != nil || viewModel.fullName.count >= 2)
    }

    enum FocusedField {
        case nickname, email, fullName
    }
    @FocusState private var focusedField: FocusedField?

    init(caregiverManager: CaregiverManager, isCreatingInvitation: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: InvitationViewModel(caregiverManager: caregiverManager))
        self._isCreatingInvitation = isCreatingInvitation
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                if viewModel.caregiverManager.profile?.fullName == nil {
                    Section(header: fullNameHeader) {
                        TextField(text: $viewModel.fullName) {
                            Text(LocalizedString("Your Full Name", comment: "Placeholder text for your full name field of invite caregiver form"))
                        }
                        .focused($focusedField, equals: .fullName)
                        .textContentType(.name)
                    }
                }
                
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
            
            continueTray
        }
        .onAppear {
            focusedField = viewModel.caregiverManager.profile == nil ? .fullName : .nickname
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
    
    var fullNameHeader: some View {
        Text("We need to know your name so that followers can identify you.")
            .textCase(nil)
            .font(.body)
            .foregroundColor(.primary)
            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 18, trailing: 0))
    }

    var header: some View {
        Text(String(format: LocalizedString("To share your %1$@ activity with a new caregiver, enter their name and email address. Then tap Continue to set up their alerts and alarms.", comment: "Format string for section header on New Caregiver page"), appName))
            .textCase(nil)
            .font(.body)
            .foregroundColor(.primary)
            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 18, trailing: 0))
    }
    
    var footer: some View {
        Text("All fields are required for a new invite.")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var continueTray: some View {
        NavigationLink {
            AlertConfigurationView(viewModel: viewModel, isCreatingInvitation: $isCreatingInvitation)
        } label: {
            Text(LocalizedString("Continue", comment: "Button title to continue to next page of invite caregiver form"))
        }
        .disabled(!formComplete)
        .animation(.default, value: formComplete)
        .buttonStyle(ActionButtonStyle())
        .padding()
        .textCase(nil)
        .background(Color(UIColor.secondarySystemGroupedBackground).edgesIgnoringSafeArea(.bottom).shadow(radius: 5))
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
