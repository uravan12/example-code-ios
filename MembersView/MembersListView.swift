import Foundation
import SwiftUI
import TurnAPI
import CoreUI

struct MembersListView: View {
    @EnvironmentObject var eturnManager: EturnManager
    @Binding var members: [EturnMember]
    @Binding var moderators: [EturnMember]
    @Binding var requestMembers: [EturnMember]
    @Binding var blockedMembers: [EturnMember]
    @Binding var invitedMembers: [EturnMember]
    @Binding var membersCount: MembersCount?
    @Binding var selectedList: SelectedList
    var onAcceptMember: () -> Void
    var body: some View {
        VStack {
            let listToShow = selectedList == .joinRequests ? requestMembers :
            selectedList == .blocked ? blockedMembers
            : selectedList == .moderatorRequests ? invitedMembers : members
            if listToShow.isEmpty {
                HStack {
                    Spacer()
                    Text("Выбранный список пуст")
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.vertical, 50)
            }
            VStack {
                if !listToShow.isEmpty {
                    if selectedList == .members || selectedList == .joinRequests {
                            VStack {
                                ForEach(Array(listToShow.enumerated()), id: \.element.id) { index, member in
                                    HStack(alignment: .top) {
                                        HStack {
                                            Text("\(member.userName) \(member.group)")
                                                .padding(.trailing, 10)
                                                .font(.system(size: 16))
                                                .foregroundColor(.black)
                                                .lineLimit(1)
                                                .padding(0)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(0)
                                        .padding(.bottom, 12)
                                        .padding(.top, 3)
                                        .padding(.horizontal, 15)
                                        switch selectedList {
                                        case .moderatorRequests:
                                            HStack {
                                                Button {
                                                    acceptMember(id: member.id, status: true, isModerator: true)
                                                } label: {
                                                    Image(.Eturn.acceptButton)
                                                }
                                                Button {
                                                    
                                                } label: {
                                                    Image(.Eturn.cancelButton)
                                                }
                                                .padding(.trailing, 10)
                                            }
                                        case .joinRequests:
                                            HStack {
                                                Button {
                                                    acceptMember(id: member.id, status: true, isModerator: false)
                                                } label: {
                                                    Image(.Eturn.acceptButton)
                                                }
                                                Button {
                                                    
                                                } label: {
                                                    Image(.Eturn.cancelButton)
                                                }
                                                .padding(.trailing, 10)
                                            }
                                        case .blocked:
                                            Button {
                                                deleteMember(id: member.id, type: "MEMBER")
                                            } label: {
                                                Image(.Eturn.unlockButton)
                                            }
                                            .padding(.horizontal)
                                        default:
                                            Button {
                                                deleteMember(id: member.id, type: "BLOCKED")
                                            } label: {
                                                Image(.Eturn.cancelButton)
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                    .opacity(selectedList == .joinRequests && index != 0 ? 0.5 : 1.0)
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
                    else {
                        ForEach(Array(listToShow.enumerated()), id: \.element.id) { index, member in
                            HStack(alignment: .top) {
                                HStack {
                                    Text("\(member.userName) \(member.group)")
                                        .padding(.trailing, 10)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                        .padding(0)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(0)
                                .padding(.bottom, 12)
                                .padding(.top, 3)
                                .padding(.horizontal, 15)
                                switch selectedList {
                                case .moderatorRequests:
                                    HStack {
                                        Button {
                                            acceptMember(id: member.id, status: true, isModerator: true)
                                        } label: {
                                            Image(.Eturn.acceptButton)
                                        }
                                        Button {
                                            
                                        } label: {
                                            Image(.Eturn.cancelButton)
                                        }
                                        .padding(.trailing, 10)
                                    }
                                case .joinRequests:
                                    HStack {
                                        Button {
                                            acceptMember(id: member.id, status: true, isModerator: false)
                                        } label: {
                                            Image(.Eturn.acceptButton)
                                        }
                                        Button {
                                            
                                        } label: {
                                            Image(.Eturn.cancelButton)
                                        }
                                        .padding(.trailing, 10)
                                    }
                                case .blocked:
                                    Button {
                                        deleteMember(id: member.id, type: "MEMBER")
                                    } label: {
                                        Image(.Eturn.unlockButton)
                                    }
                                    .padding(.horizontal)
                                default:
                                    Button {
                                        deleteMember(id: member.id, type: "BLOCKED")
                                    } label: {
                                        Image(.Eturn.cancelButton)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .opacity(selectedList == .joinRequests && index != 0 ? 0.5 : 1.0)
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
    public func acceptMember(id: Int, status: Bool, isModerator: Bool) {
        if isModerator == true {
            eturnManager.acceptMember(id: id, status: status, isModerator: isModerator) { result in
                if result {
                    if let index = invitedMembers.firstIndex(where: { $0.id == id }) {
                        let removedMember = invitedMembers.remove(at: index)
                        moderators.append(removedMember)
                        onAcceptMember()
                        
                        if membersCount?.moderatorInvited != nil {
                            membersCount?.moderatorInvited -= 1
                        }
                        if membersCount?.member != nil && membersCount?.member != 0 {
                            membersCount?.member -= 1
                        }
                    }
                }
            }
        }
        else {
            eturnManager.acceptMember(id: id, status: status, isModerator: isModerator) { result in
                if result {
                    if let index = requestMembers.firstIndex(where: { $0.id == id }) {
                        let removedMember = requestMembers.remove(at: index)
                        members.append(removedMember)
                        
                        if membersCount?.memberInvited != nil {
                            membersCount?.memberInvited -= 1
                        }
                        if membersCount?.member != nil {
                            membersCount?.member += 1
                        }
                    }
                }
            }
            
        }
    }
    func deleteMember(id: Int, type: String) {
        if type == "BLOCKED" {
            eturnManager.editType(id: id, type: type) { result in
                if result {
                    if let index = members.firstIndex(where: { $0.id == id }) {
                        let removedMember = members.remove(at: index)
                        blockedMembers.append(removedMember)
                        if membersCount?.member != nil {
                            membersCount?.member -= 1
                        }
                        if membersCount?.blocked != nil {
                            membersCount?.blocked += 1
                        }
                    }
                }
            }
        }
        else {
            eturnManager.editType(id: id , type: type) { result in
                if result {
                    if let index = blockedMembers.firstIndex(where: { $0.id == id }) {
                        let removedMember = blockedMembers.remove(at: index)
                        onAcceptMember()
                        if membersCount?.blocked != nil {
                            membersCount?.blocked -= 1
                        }
                    }
                }
            }
        }
    }
}
