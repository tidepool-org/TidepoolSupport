//
//  InitialNotificationsView.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/8/23.
//

import SwiftUI

extension Double: Identifiable {
    public var id: Double {
        return self
    }
}

struct AlertConfigurationView: View {

    @ObservedObject var viewModel: InvitationViewModel
    @Binding var isCreatingInvitation: Bool

    struct ThresholdValue: Identifiable {
        var id: Double {
            return value
        }

        let value: Double
    }

    var body: some View {
        Form {
            Section(header: header)
            {
                Toggle("Urgent Low", isOn: $viewModel.urgentLowEnabled)
                if viewModel.urgentLowEnabled {
                    Picker("Notify Below", selection: $viewModel.urgentLowThreshold) {
                        ForEach(viewModel.urgentLowThresholdValues) { value in
                            Text(viewModel.valueFormatter.string(from: value as NSNumber)! + " mg/dL")
                        }
                    }
                }
            }
            Section() {
                Toggle("Low", isOn: $viewModel.lowEnabled)
                if viewModel.lowEnabled {
                    Picker("Notify Below", selection: $viewModel.lowThreshold) {
                        ForEach(viewModel.lowThresholdValues) { value in
                            Text(viewModel.valueFormatter.string(from: value as NSNumber)! + " mg/dL")
                        }
                    }
                    Picker("For More Than", selection: $viewModel.lowDelay) {
                        ForEach(viewModel.lowDelayValues) { value in
                            Text(viewModel.timeIntervalFormatter.string(from: value)!)
                        }
                    }
                }
            }
            Section() {
                Toggle("High", isOn: $viewModel.highEnabled)
                if viewModel.highEnabled {
                    Picker("Notify Above", selection: $viewModel.highThreshold) {
                        ForEach(viewModel.highThresholdValues) { value in
                            Text(viewModel.valueFormatter.string(from: value as NSNumber)! + " mg/dL")
                        }
                    }
                    Picker("For More Than", selection: $viewModel.highDelay) {
                        ForEach(viewModel.highDelayValues) { value in
                            Text(viewModel.timeIntervalFormatter.string(from: value)!)
                        }
                    }
                }
            }
            Section() {
                Toggle("Not Looping", isOn: $viewModel.notLoopingEnabled)
                if viewModel.notLoopingEnabled {
                    Picker("For More Than", selection: $viewModel.notLoopingDelay) {
                        ForEach(viewModel.notLoopingDelayValues) { value in
                            Text(viewModel.timeIntervalFormatter.string(from: value)!)
                        }
                    }
                }
            }
            Section(footer: noCommunicationFooter) {
                Toggle("No Communication", isOn: $viewModel.noCommunicationEnabled)
                if viewModel.noCommunicationEnabled {
                    Picker("For More Than", selection: $viewModel.noCommunicationDelay) {
                        ForEach(viewModel.noCommunicationDelayValues) { value in
                            Text(viewModel.timeIntervalFormatter.string(from: value)!)
                        }
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    InvitationSubmitView(viewModel: viewModel, isCreatingInvitation: $isCreatingInvitation)
                } label: {
                    Text("Next")
                }
                .isDetailLink(false)
            }
        }
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(LocalizedString("Configure the notifications you would like your caregiver to receive. Caregivers will be able to change this configuration later on.", comment: "Text of section header on the new caregiver alert configuration page"))
                .textCase(nil)
                .font(.body)
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
