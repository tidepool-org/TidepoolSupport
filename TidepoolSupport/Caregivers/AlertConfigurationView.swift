//
//  InitialNotificationsView.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/8/23.
//

import SwiftUI
import HealthKit
import LoopKitUI
import LoopKit

extension Double: Identifiable {
    public var id: Double {
        return self
    }
}

struct AlertConfigurationView: View {
    @EnvironmentObject private var glucosePreference: DisplayGlucosePreference

    @ObservedObject var viewModel: InvitationViewModel
    @Binding var isCreatingInvitation: Bool
    @State var cancelConfirmationShown: Bool = false

    struct ThresholdValue: Identifiable {
        var id: Double {
            return value
        }

        let value: Double
    }

    func formatGlucose(_ glucose: Double) -> String {
        return glucosePreference.formatter.string(from: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: glucose))!
    }

    var body: some View {
        VStack(spacing: 0) {
            form
            VStack {
                NavigationLink {
                    InvitationSubmitView(viewModel: viewModel, isCreatingInvitation: $isCreatingInvitation)
                } label: {
                    Text(LocalizedString("Continue", comment: "Button title for navigating to next page of caregiver invitation form"))
                }
                .actionButtonStyle()
                .padding()
            }
            .background(Color(UIColor.secondarySystemGroupedBackground).shadow(radius: 5))
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle(LocalizedString("Notifications", comment: "Navigation title for notification configuration page of caregiver invitation"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(LocalizedString("Cancel", comment: "Button title to cancel sending of caregiver invitation")) {
                    cancelConfirmationShown = true
                }
            }
        }
        .confirmationDialog(LocalizedString("Close Invitation?", comment: "Title of confirmation dialog for closing invitation"), isPresented: $cancelConfirmationShown) {
            Button(LocalizedString("Close Invite", comment: "Button to confirm closing invitation"), role: .destructive) {
                isCreatingInvitation = false
            }
        } message: {
            Text(LocalizedString("If you leave now, you will need to create this invitation again.", comment: "Message of confirmation dialog for closing invitation"))
        }
    }

    var form: some View {
        Form {
            Section(header: header)
            {
                Toggle(LocalizedString("Urgent Low", comment: "Title of urgent low alert"), isOn: $viewModel.urgentLowEnabled)
                if viewModel.urgentLowEnabled {
                    Picker(LocalizedString("Notify Below", comment: "Title of urgent low alert threshold"), selection: $viewModel.urgentLowThreshold) {
                        ForEach(viewModel.urgentLowThresholdValues) { value in
                            Text(formatGlucose(value))
                        }
                    }
                }
            }
            Section() {
                Toggle(LocalizedString("Low", comment: "Title of low alert"), isOn: $viewModel.lowEnabled)
                if viewModel.lowEnabled {
                    Picker(LocalizedString("Notify Below", comment: "Title of low alert threshold"), selection: $viewModel.lowThreshold) {
                        ForEach(viewModel.lowThresholdValues) { value in
                            Text(formatGlucose(value))
                        }
                    }
                    Picker(LocalizedString("For More Than", comment: "Title of alert delay value"), selection: $viewModel.lowDelay) {
                        ForEach(viewModel.lowDelayValues) { value in
                            Text(viewModel.timeIntervalFormatter.string(from: value)!)
                        }
                    }
                }
            }
            Section() {
                Toggle(LocalizedString("High", comment: "Title of high alert"), isOn: $viewModel.highEnabled)
                if viewModel.highEnabled {
                    Picker(LocalizedString("Notify Above", comment: "Title of high alert threshold value"), selection: $viewModel.highThreshold) {
                        ForEach(viewModel.highThresholdValues) { value in
                            Text(formatGlucose(value))
                        }
                    }
                    Picker(LocalizedString("For More Than", comment: "Title of alert delay value"), selection: $viewModel.highDelay) {
                        ForEach(viewModel.highDelayValues) { value in
                            Text(viewModel.timeIntervalFormatter.string(from: value)!)
                        }
                    }
                }
            }
            Section() {
                Toggle(LocalizedString("Not Looping", comment: "Title of not looping alert"), isOn: $viewModel.notLoopingEnabled)
                if viewModel.notLoopingEnabled {
                    Picker(LocalizedString("For More Than", comment: "Title of alert delay value"), selection: $viewModel.notLoopingDelay) {
                        ForEach(viewModel.notLoopingDelayValues) { value in
                            Text(viewModel.timeIntervalFormatter.string(from: value)!)
                        }
                    }
                }
            }
            Section(footer: noCommunicationFooter) {
                Toggle(LocalizedString("No Communication", comment: "Title of no communication alert"), isOn: $viewModel.noCommunicationEnabled)
                if viewModel.noCommunicationEnabled {
                    Picker(LocalizedString("For More Than", comment: "Title of alert delay value"), selection: $viewModel.noCommunicationDelay) {
                        ForEach(viewModel.noCommunicationDelayValues) { value in
                            Text(viewModel.timeIntervalFormatter.string(from: value)!)
                        }
                    }
                }
            }
        }
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(LocalizedString("Configure the notifications you would like your caregiver to receive. Caregivers will be able to change this configuration later on.", comment: "Text of section header on the new caregiver alert configuration page"))
                .textCase(nil)
                .font(.body.weight(.semibold))
                .foregroundColor(.primary)
            Divider()
                .overlay(.primary)
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 18, trailing: 0))
    }

    var noCommunicationFooter: some View {
        Text(LocalizedString("This alert lets a caregiver know when communication between Tidepool Loop and the Care Partner app is down. The caregiver should rely on a secondary method for communication until communication is restored.", comment: "Footer text for no communication notification configuration section"))
    }

}

struct InitialNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlertConfigurationView(viewModel: InvitationViewModel.mock, isCreatingInvitation: .constant(true))
        }
    }
}
