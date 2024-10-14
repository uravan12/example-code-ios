import Foundation
import SwiftUI
import TurnAPI
import CoreUI

struct MembersShowView: View {
    @EnvironmentObject var eturnManager: EturnManager
    @Binding var members: [EturnMember]
    @Binding var blockedMembers: [EturnMember]
    @Binding var invitedMembers: [EturnMember]
    @Binding var membersCount: MembersCount?
    var turnHash: String
    @State private var page = 0
    @Binding var isLoading: Bool
    @State var isLoading2 = false
    @State private var hasReachedEnd = false
    var body: some View {
        Group {
            if members.isEmpty {
                HStack {
                    Spacer()
                    Text("В очереди пока никого нет")
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.vertical, 50)
            } else {
                LazyVStack {
                    ForEach(members.indices, id: \.self) { index in
                        MemberShowView(
                            member: members[index],
                            membersCount: $membersCount,
                            members: $members,
                            updateBlocked: updateBlocked,
                            updateModerRequests: updateModeratorsRequests
                        )
                        .onAppear {
                            print("onAppear: index = \(index), id = \(members[index].id), page = \(page), isLoading = \(isLoading2), hasReachedEnd = \(hasReachedEnd)")
                            if index == (20 * page) + 10 && !isLoading2 && !hasReachedEnd {
                                isLoading2 = true
                                page += 1
                                loadMore()
                            }
                        }
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
        if members.isEmpty {
            loadMore()
        } else {
            isLoading = false
        }
        }
    }
    func loadMore() {
        print("loadMore() called: page = \(page), isLoading = \(isLoading2), hasReachedEnd = \(hasReachedEnd)")
        eturnManager.fetchMembers(hash: turnHash, type: "MEMBER", page: page) { result in
            switch result {
            case .success(let fetchedInvitedMembers):
                if page == 0 {
                    self.members = fetchedInvitedMembers.list
                    isLoading = false
                    membersCount?.member = fetchedInvitedMembers.count
                    if fetchedInvitedMembers.list.isEmpty {
                        hasReachedEnd = true
                    }
                } else {
                    let newMembers = fetchedInvitedMembers.list.filter { newMember in
                            !self.members.contains { existingMember in
                            newMember.id == existingMember.id
                        }
                    }
                    self.members.append(contentsOf: newMembers)
                    isLoading = false
                    membersCount?.member = fetchedInvitedMembers.count
                    if newMembers.isEmpty {
                        hasReachedEnd = true
                    }
                }
                isLoading = false
                isLoading2 = false
                print("Members111: \(members)")
                print("Count: \(String(describing: membersCount?.member))")
            case .failure(let error):
                print("Error fetching \(error)")
                isLoading = false
                isLoading2 = false
            }
            print("loadMore() finished: page = \(page), isLoading = \(isLoading2), hasReachedEnd = \(hasReachedEnd)")
        }
    }
    func updateBlocked() {
        eturnManager.fetchMembers(hash: turnHash, type: "BLOCKED", page: page) { result in
            switch result {
            case .success(let fetchedInvitedMembers):
                self.blockedMembers = fetchedInvitedMembers.list
                membersCount?.blocked = fetchedInvitedMembers.count
                isLoading2 = false
            case .failure(let error):
                print("Error fetching \(error)")
                isLoading2 = false
            }
        }
    }
    func updateModeratorsRequests() {
            eturnManager.fetchInvited(hash: turnHash, type: "MODERATOR", page: 0) { result in
                switch result {
                case .success(let fetchedInvitedMembers):
                    let newMembers = fetchedInvitedMembers.list.filter { newMember in
                         !self.invitedMembers.contains { existingMember in
                         newMember.id == existingMember.id
                       }
                   }
                    self.invitedMembers = newMembers
                    membersCount?.moderatorInvited = fetchedInvitedMembers.count
                    print("WORK!! \(invitedMembers)")
                    isLoading2 = false
                case .failure(let error):
                    print("Error fetching \(error)")
                }
            }
    }
}
