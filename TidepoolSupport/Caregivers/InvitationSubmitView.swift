//
//  InvitationSubmitView.swift
//  LoopCaregiverInvite
//
//  Created by Pete Schwamb on 5/9/23.
//

import SwiftUI
import HealthKit
import LoopKitUI
import LoopKit

struct InvitationSubmitView: View {
    @EnvironmentObject private var glucosePreference: DisplayGlucosePreference

    @ObservedObject var viewModel: InvitationViewModel
    @Binding var isCreatingInvitation: Bool
    
    private let nicknameStorage = UserDefaults.standard

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

    func formatGlucose(_ glucose: Double) -> String {
        return glucosePreference.formatter.string(from: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: glucose))!
    }

    @State var sendState: SendState = .idle

    init(viewModel: InvitationViewModel, isCreatingInvitation: Binding<Bool>) {
        self.viewModel = viewModel
        self._isCreatingInvitation = isCreatingInvitation
    }

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
        labelRow(name, formatGlucose(value))
    }

    func delayRow(_ name: String, _ value: TimeInterval) -> some View {
        labelRow(name, viewModel.timeIntervalFormatter.string(from: value)!)
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: header) {
                    labelRow(LocalizedString("Caregiver Nickname", comment: "Label text for reviewing caregiver invitation nickname"), viewModel.nickname)
                    labelRow(LocalizedString("Email", comment: "Label text for reviewing caregiver invitation email"), viewModel.email)
                }
                Section
                {
                    alertEnabledRow(LocalizedString("Urgent Low", comment: "Title of urgent low alert"), viewModel.urgentLowEnabled)
                    if viewModel.urgentLowEnabled {
                        thresholdRow(LocalizedString("Notify Below", comment: "Title of urgent low alert threshold"), viewModel.urgentLowThreshold)
                    }
                }
                Section() {
                    alertEnabledRow(LocalizedString("Low", comment: "Title of low alert"), viewModel.lowEnabled)
                    if viewModel.lowEnabled {
                        thresholdRow(LocalizedString("Notify Below", comment: "Title of low alert threshold"), viewModel.lowThreshold)
                        delayRow(LocalizedString("For More Than", comment: "Title of alert delay value"), viewModel.lowDelay)
                    }
                }
                Section() {
                    alertEnabledRow(LocalizedString("High", comment: "Title of high alert"), viewModel.highEnabled)
                    if viewModel.highEnabled {
                        thresholdRow(LocalizedString("Notify Above", comment: "Title of high alert threshold value"), viewModel.highThreshold)
                        delayRow(LocalizedString("For More Than", comment: "Title of delay value"), viewModel.highDelay)
                    }
                }
                Section() {
                    alertEnabledRow(LocalizedString("Not Looping", comment: "Title of not looping alert"), viewModel.notLoopingEnabled)
                    if viewModel.notLoopingEnabled {
                        delayRow(LocalizedString("For More Than", comment: "Title of alert delay value"), viewModel.notLoopingDelay)
                    }
                }
                Section() {
                    alertEnabledRow(LocalizedString("No Communication", comment: "Title of no communication alert"), viewModel.noCommunicationEnabled)
                    if viewModel.noCommunicationEnabled {
                        delayRow(LocalizedString("For More Than", comment: "Title of alert delay value"), viewModel.noCommunicationDelay)
                    }
                }
            }
            .listStyle(.insetGrouped)

            VStack(spacing: 0) {
                switch sendState {
                case .error(let error):
                    errorView(error)
                        .padding([.top, .horizontal])
                case .sent:
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(Font.system(.largeTitle))
                        Text(LocalizedString("Invite Sent!", comment: "Success message for caregiver invitation creation"))
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
                                // MARK: Temporary local storage save for nickname
                                nicknameStorage.set(viewModel.nickname, forKey: viewModel.email)
                                let _ = try await viewModel.submit()
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
                        isCreatingInvitation = false
                        break
                    default:
                        break
                    }
                } label: {
                    switch sendState {
                    case .sending:
                        ProgressView()
                    case .sent:
                        Text(LocalizedString("Continue", comment: "Button title to continue"))
                    default:
                        Text(LocalizedString("Send Invite", comment: "Button title to send caregiver invitation"))
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
        .navigationTitle(LocalizedString("Send Invitation", comment: "Navigation bar title on submit caregiver invitation page"))
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(sendState.isSent || sendState.isSending)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(LocalizedString("Cancel", comment: "Button title to cancel sending of caregiver invitation")) {
                    isCreatingInvitation = false
                }
                .disabled(sendState.isSent || sendState.isSending)
            }
        }
    }

    func errorView(_ error: Error) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(LocalizedString("Invite failed to send.", comment: "Failure message when caregiver invitation fails during sending."))
                    .bold()
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }
            Text((error as? LocalizedError)?.recoverySuggestion ?? error.localizedDescription)
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
            InvitationSubmitView(viewModel: InvitationViewModel.mock, isCreatingInvitation: .constant(true))
        }
    }
}
