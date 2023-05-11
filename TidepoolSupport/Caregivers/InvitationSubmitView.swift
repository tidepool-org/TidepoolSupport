//
//  InvitationSubmitView.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/9/23.
//

import SwiftUI

struct InvitationSubmitView: View {

    @ObservedObject var viewModel: InvitationViewModel

    enum SendState {
        case idle
        case error(Error)
        case sending
        case sent

        var isSending: Bool {
            switch self {
            case .sending:
                return true
            default:
                return false
            }
        }

        var isSent: Bool {
            switch self {
            case .sent:
                return true
            default:
                return false
            }
        }
    }

    @State var sendState: SendState = .idle

    func labelRow(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(value).foregroundColor(.secondary)
        }
    }

    func alertEnabledRow(_ name: String, _ enabled: Bool) -> some View {
        labelRow(name,
                 enabled ?
                 LocalizedString("On", comment: "Label when an alert is enabled") :
                 LocalizedString("Off", comment: "Label when an alert is not enabled")
        )
    }

    func thresholdRow(_ name: String, _ value: Double) -> some View {
        labelRow(name, viewModel.valueFormatter.string(from: value as NSNumber)! + " mg/dL")
    }

    func delayRow(_ name: String, _ value: TimeInterval) -> some View {
        labelRow(name, viewModel.timeIntervalFormatter.string(from: value)!)
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: header) {
                    labelRow("Caregiver Nickname", viewModel.nickname)
                    labelRow("Email", viewModel.email)
                }
                Section
                {
                    alertEnabledRow("Urgent Low", viewModel.urgentLowEnabled)
                    if viewModel.urgentLowEnabled {
                        thresholdRow("Notify Below", viewModel.urgentLowThreshold)
                    }
                }
                Section() {
                    alertEnabledRow("Low", viewModel.lowEnabled)
                    if viewModel.lowEnabled {
                        thresholdRow("Notify Below", viewModel.lowThreshold)
                        delayRow("For More Than", viewModel.lowDelay)
                    }
                }
                Section() {
                    alertEnabledRow("High", viewModel.highEnabled)
                    if viewModel.highEnabled {
                        thresholdRow("Notify Above", viewModel.highThreshold)
                        delayRow("For More Than", viewModel.highDelay)
                    }
                }
                Section() {
                    alertEnabledRow("Not Looping", viewModel.notLoopingEnabled)
                    if viewModel.notLoopingEnabled {
                        delayRow("For More Than", viewModel.notLoopingDelay)
                    }
                }
                Section() {
                    alertEnabledRow("No Communication", viewModel.noCommunicationEnabled)
                    if viewModel.noCommunicationEnabled {
                        delayRow("For More Than", viewModel.noCommunicationDelay)
                    }
                }
            }
            .listStyle(.insetGrouped)

            VStack(spacing: 0) {
                switch sendState {
                case .error(let error):
                    VStack(alignment: .leading, spacing: 10) {
                        Label {
                            Text("Invite failed to send.")
                                .bold()
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                        }
                        if let error = error as? LocalizedError, let recoverySuggestion = error.recoverySuggestion {
                            Text(recoverySuggestion)
                        }
                    }
                    .padding([.top, .horizontal])
                case .sent:
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(Font.system(.largeTitle))
                        Text("Invite Sent!")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.top, .horizontal])
                default:
                    EmptyView()
                }
                Button {
                    switch sendState {
                    case .idle, .error:
                        Task {
                            do {
                                withAnimation {
                                    sendState = .sending
                                }
                                try await viewModel.submit()
                                withAnimation {
                                    sendState = .sent
                                }
                            } catch {
                                withAnimation {
                                    sendState = .error(error)
                                }
                            }
                        }
                    case .sent:
                        // TODO: Navigate to caregiver mgmt
                        break
                    default:
                        break
                    }
                } label: {
                    switch sendState {
                    case .sending:
                        ProgressView()
                    case .sent:
                        Text("Continue")
                    default:
                        Text("Send Invite")
                    }
                }
                .actionButtonStyle(.primary)
                .textCase(nil)
                .disabled(sendState.isSending)
                .padding()
            }
            .background(Color(UIColor.secondarySystemGroupedBackground).shadow(radius: 5))
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("Send Invitation")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(sendState.isSent || sendState.isSending)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    print("Cancel tapped!")
                }
                .disabled(sendState.isSent || sendState.isSending)
            }
        }
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(LocalizedString("Review the information below. Then tap Send Invite to invite your caregiver to view your data.", comment: "Text of section header on the send invitation page"))
                .textCase(nil)
                .font(.body)
            Divider()
                .overlay(.primary)
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 18, trailing: 0))
    }

}

struct InvitationSubmitView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InvitationSubmitView(viewModel: InvitationViewModel())
        }
    }
}
