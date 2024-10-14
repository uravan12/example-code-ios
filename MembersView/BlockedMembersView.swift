import Foundation
import SwiftUI
import TurnAPI
import CoreUI

struct BlockedMembersView: View {
    @EnvironmentObject var eturnManager: EturnManager
    @Binding var blockedMembers: [EturnMember]
    @Binding var membersCount: MembersCount?
    var turnHash: String
    @State private var page = 0
    @Binding var isLoading: Bool
    @State private var isLoading2 = false
    @State private var hasReachedEnd = false
    var body: some View {
        Group {
            if blockedMembers.isEmpty {
                HStack {
                    Spacer()
                    Text("Нет заблокированных участников")
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.vertical, 50)
            } else {
                LazyVStack {
                    ForEach(blockedMembers.indices, id: \.self) { index in
                        BlockedMemberView(
                            blockedMember: blockedMembers[index],
                            membersCount: $membersCount,
                            blockedMembers: $blockedMembers
                        )
                        .onAppear {
                            print("onAppear: index = \(index), id = \(blockedMembers[index].id), page = \(page), isLoading = \(isLoading2), hasReachedEnd = \(hasReachedEnd)")
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
        if blockedMembers.isEmpty {
            loadMore()
        } else {
            isLoading = false
        }
        }
    }
    func loadMore() {
        print("loadMore() called: page = \(page), isLoading = \(isLoading2), hasReachedEnd = \(hasReachedEnd)")
        eturnManager.fetchMembers(hash: turnHash, type: "BLOCKED", page: page) { result in
            switch result {
            case .success(let fetchedInvitedMembers):
                if page == 0 {
                    self.blockedMembers = fetchedInvitedMembers.list
                    membersCount?.blocked = fetchedInvitedMembers.count
                    if fetchedInvitedMembers.list.isEmpty {
                        hasReachedEnd = true
                    }
                } else {
                    let newMembers = fetchedInvitedMembers.list.filter { newMember in
                            !self.blockedMembers.contains { existingMember in
                            newMember.id == existingMember.id
                        }
                    }
                    self.blockedMembers.append(contentsOf: newMembers)
                    membersCount?.blocked = fetchedInvitedMembers.count
                    if newMembers.isEmpty {
                        hasReachedEnd = true
                    }
                }
                isLoading = false
                isLoading2 = false
                print("Blocked: \(blockedMembers)")
            case .failure(let error):
                print("Error fetching \(error)")
                isLoading = false
                isLoading2 = false
            }
            print("loadMore() finished: page = \(page), isLoading = \(isLoading2), hasReachedEnd = \(hasReachedEnd)")
        }
    }
}


