import Foundation
import SwiftUI
import TurnAPI
import CoreUI
struct ShowMemberList: View {
    var turnHash: String
    @EnvironmentObject var eturnManager: EturnManager
    @Binding var members: [EturnMember]
    @Binding var moderators: [EturnMember]
    @Binding var requestMembers: [EturnMember]
    @Binding var blockedMembers: [EturnMember]
    @Binding var invitedMembers: [EturnMember]
    @Binding var selectedList: SelectedList
    @Binding var membersCount: MembersCount?
    @Binding var rateVisible: Bool
    @State var isLoading: Bool = true
    @State private var initialSelectedList: SelectedList? = nil
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            switch selectedList {
            case .moderatorRequests:
                ShowListsMembers(
                    turnHash: turnHash,
                    membersCount: Binding(
                        get: { membersCount?.moderatorInvited ?? 0 },
                        set: { newValue in membersCount?.moderatorInvited = newValue ?? 0 }
                    ),
                    selectedList: $selectedList,
                    visible: $rateVisible
                )
                ZStack {
                    ModeratorsRequestsMembersView(
                        invitedMembers: $invitedMembers,
                        moderators: $moderators,
                        members: $members,
                        membersCount: $membersCount,
                        turnHash: turnHash,
                        isLoading: $isLoading
                    )
                    .opacity(isLoading ? 0 : 1)
                    if isLoading {
                        SpinnerView()
                            .padding(.top, 40)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
            case .joinRequests:
                ShowListsMembers(
                    turnHash: turnHash,
                    membersCount: Binding(
                        get: { membersCount?.memberInvited ?? 0 },
                        set: { newValue in membersCount?.memberInvited = newValue ?? 0 }
                    ),
                    selectedList: $selectedList,
                    visible: $rateVisible
                )
                ZStack {
                    JoinRequestsMembersView(
                        requestMembers: $requestMembers,
                        moderators: $moderators,
                        members: $members,
                        membersCount: $membersCount,
                        turnHash: turnHash,
                        isLoading: $isLoading
                    )
                    .opacity(isLoading ? 0 : 1)
                    if isLoading {
                        SpinnerView()
                            .padding(.top, 40)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
            case .blocked:
                ShowListsMembers(
                    turnHash: turnHash,
                    membersCount: Binding(
                        get: { membersCount?.blocked ?? 0 },
                        set: { newValue in membersCount?.blocked = newValue ?? 0 }
                    ),
                    selectedList: $selectedList,
                    visible: $rateVisible
                )
                ZStack {
                    BlockedMembersView(
                        blockedMembers: $blockedMembers,
                        membersCount: $membersCount,
                        turnHash: turnHash,
                        isLoading: $isLoading
                    )
                    .opacity(isLoading ? 0 : 1)
                    if isLoading {
                        SpinnerView()
                            .padding(.top, 40)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
            default:
                ShowListsMembers(
                    turnHash: turnHash,
                    membersCount: Binding(
                        get: { membersCount?.member ?? 0 },
                        set: { newValue in membersCount?.member = newValue ?? 0 }
                    ),
                    selectedList: $selectedList,
                    visible: $rateVisible
                )
                ZStack {
                    MembersShowView(
                        members: $members,
                        blockedMembers: $blockedMembers,
                        invitedMembers: $invitedMembers,
                        membersCount: $membersCount,
                        turnHash: turnHash,
                        isLoading: $isLoading
                    )
                    .opacity(isLoading ? 0 : 1)
                    if isLoading {
                        SpinnerView()
                            .padding(.top, 40)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
            }
        }
        .onAppear {
            if initialSelectedList == nil {
                initialSelectedList = determineInitialList()
                selectedList = initialSelectedList!
            }
        }
        .onChange(of: selectedList) { newSelectedList in
            isLoading = true
        }
    }
    private func getMembersCount(for selectedList: SelectedList) -> Int? {
            switch selectedList {
            case .members:
                return membersCount?.member
            case .moderatorRequests:
                return membersCount?.moderatorInvited
            case .joinRequests:
                return membersCount?.memberInvited
            case .blocked:
                return membersCount?.blocked
            }
        }
    private func determineInitialList() -> SelectedList {
            guard let membersCount = membersCount else {
                return .members
            }

            if membersCount.moderatorInvited > 0 {
                return .moderatorRequests
            } else if membersCount.memberInvited > 0 {
                return .joinRequests
            } else if membersCount.member > 0 {
                return .members
            } else if membersCount.blocked > 0 {
                return .blocked
            } else {
                return .members
            }
        }
}
