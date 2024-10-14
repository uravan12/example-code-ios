import Foundation
import SwiftUI
import TurnAPI
import CoreUI

struct ModeratorRequestMemberView: View {
    @EnvironmentObject var eturnManager: EturnManager
    var invitedMember: EturnMember
    @Binding var membersCount: MembersCount?
    @Binding var invitedMembers: [EturnMember]
    @Binding var moderators: [EturnMember]
    @Binding var members: [EturnMember]
    @State private var isPushedAcceptButton = false
    @State private var isPushedDeclineButton = false
    var updateMembers: () -> Void
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                Text("\(invitedMember.userName) \(invitedMember.group)")
                    .padding(.trailing, 10)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(0)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
            HStack {
                Button {
                    isPushedAcceptButton = true
                    acceptMember(id: invitedMember.id, status: true, isModerator: true)
                } label: {
                    if isPushedAcceptButton {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: ColorPalette.green25))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .frame(width: 40, height: 40, alignment: .topLeading)
                    } else {
                        Image(.Eturn.acceptButton)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(ColorPalette.green200)
                            .padding(.horizontal, 5)
                            .frame(width: 40, height: 40, alignment: .topLeading)
                    }
                }
                Button {
                    isPushedDeclineButton = true
                    acceptMember(id: invitedMember.id, status: false, isModerator: true)
                } label: {
                    if isPushedDeclineButton {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: ColorPalette.red155))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .frame(width: 40, height: 40, alignment: .topLeading)
                    } else {
                        Image(.Eturn.cancelButton)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(ColorPalette.green200)
                            .padding(.horizontal, 5)
                            .frame(width: 40, height: 40, alignment: .topLeading)

                    }
                }
                .padding(.trailing, 10)
            }
        }
    }
    func acceptMember(id: Int, status: Bool, isModerator: Bool) {
        if status == true {
            eturnManager.acceptMember(id: id, status: status, isModerator: isModerator) { result in
                if status == true {
                    if let index = invitedMembers.firstIndex(where: { $0.id == id }) {
                        let removedMember = invitedMembers.remove(at: index)
                        moderators.append(removedMember)
                        if membersCount?.moderatorInvited != nil {
                            membersCount?.moderatorInvited -= 1
                        }
                    }
                    isPushedAcceptButton = false
                }
                updateMembers()
            }
        } else {
            eturnManager.acceptMember(id: id, status: status, isModerator: isModerator) { result in
                if let index = invitedMembers.firstIndex(where: { $0.id == id }) {
                    let removedMember = invitedMembers.remove(at: index)
                    if membersCount?.moderatorInvited != nil {
                        membersCount?.moderatorInvited -= 1
                    }
                }
                isPushedDeclineButton = false
                updateMembers()
            }
        }
    }
}
