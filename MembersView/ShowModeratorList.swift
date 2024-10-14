import Foundation
import SwiftUI
import TurnAPI
import CoreUI

struct ShowModeratorList: View {
    var turnHash: String
    @Binding var members: [EturnMember]
    @Binding var moderators: [EturnMember]
    @Binding var selectedList: SelectedList
    @Binding var isLoading: Bool
    @Binding var membersCount: MembersCount?
    @Binding var status: String?
    @EnvironmentObject var eturnManager: EturnManager
    var body: some View {
        VStack(alignment: .leading) {
                Text("Модераторы")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                if isLoading {
                    SpinnerView()
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ModeratorsListView(
                        turnHash: turnHash,
                        moderators: $moderators,
                        membersCount: $membersCount,
                        updateMembers: fetchMembers,
                        status: $status
                    )
                }
        }
        .onAppear {
           fetchModerators()
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    func fetchModerators() {
        eturnManager.fetchMembers(hash: turnHash, type: "MODERATOR", page: 0) { result in
            switch result {
            case .success(let fetchedMembers):
                let newMembers = fetchedMembers.list.filter { newMember in
                     !self.moderators.contains { existingMember in
                     newMember.id == existingMember.id
                   }
               }
                self.moderators.append(contentsOf: newMembers)
                membersCount?.moderator = fetchedMembers.count
                isLoading = false
                print("Moderators: \(moderators)")
            case .failure(let error):
                print("Error fetching: \(error)")
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
                self.members.append(contentsOf: newMembers)
                membersCount?.member = fetchedMembers.count
                isLoading = false
                print("Members: \(members)")
            case .failure(let error):
                print("Error fetching: \(error)")
            }
        }
    }
}
