import Foundation
import SwiftUI
import TurnAPI
import CoreUI

struct ModeratorsRequestsMembersView: View {
    @EnvironmentObject var eturnManager: EturnManager
    @Binding var invitedMembers: [EturnMember]
    @Binding var moderators: [EturnMember]
    @Binding var members: [EturnMember]
    @Binding var membersCount: MembersCount?
    var turnHash: String
    @Binding var isLoading: Bool
    var body: some View {
        Group {
            if invitedMembers.isEmpty {
                HStack {
                    Spacer()
                    Text("Новых заявок нет")
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.vertical, 50)
            } else {
                VStack {
                    ForEach(invitedMembers.indices, id: \.self) { index in
                        ModeratorRequestMemberView(
                            invitedMember: invitedMembers[index],
                            membersCount: $membersCount,
                            invitedMembers: $invitedMembers,
                            moderators: $moderators,
                            members: $members,
                            updateMembers: fetchMembers
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                        .padding(.horizontal)
                )
                .padding(.top, 15)
            }
        }
        .onAppear {
            fetchInvitedMembers()
        }
    }
    func fetchInvitedMembers() {
            eturnManager.fetchInvited(hash: turnHash, type: "MODERATOR", page: 0) { result in
                switch result {
                case .success(let fetchedInvitedMembers):
                    self.invitedMembers = fetchedInvitedMembers.list
                    membersCount?.moderatorInvited = fetchedInvitedMembers.count
                    isLoading = false
                    print("invitedMembers: \(invitedMembers)")
                case .failure(let error):
                    print("Error fetching \(error)")
                }
            }
    }
    func fetchMembers() {
        eturnManager.fetchMembers(hash: turnHash, type: "MEMBER", page: 0) { result in
            switch result {
            case .success(let fetchedMembers):
                let newMembers = fetchedMembers.list.filter { newMember in
                        !self.members.contains { existingMember in
                        newMember.id == existingMember.id
                    }
                }
                self.members = newMembers
                isLoading = false
                print("Members: \(members)")
            case .failure(let error):
                print("Error fetching: \(error)")
            }
        }
    }
}
