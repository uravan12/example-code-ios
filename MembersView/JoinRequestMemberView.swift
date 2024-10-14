import Foundation
import SwiftUI
import TurnAPI
import CoreUI

struct JoinRequestsMemberView: View {
    @EnvironmentObject var eturnManager: EturnManager
    var requestMember: EturnMember
    @Binding var membersCount: MembersCount?
    @Binding var requestMembers: [EturnMember]
    @Binding var members: [EturnMember]
    @Binding var visibleRequestMembers: [EturnMember]
    var updateVisibleRequests: () -> Void
    @State private var isPushedAcceptButton = false
    @State private var isPushedDeclineButton = false
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                Text("\(requestMember.userName) \(requestMember.group)")
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
                    acceptMember(id: requestMember.id, status: true, isModerator: false)
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
                    acceptMember(id: requestMember.id, status: false, isModerator: false)
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
                    updateVisibleRequests()
                    isPushedAcceptButton = false
                }
            }
        } else {
            eturnManager.acceptMember(id: id, status: status, isModerator: isModerator) { result in
                if result {
                    if let index = requestMembers.firstIndex(where: { $0.id == id }) {
                        let removedMember = requestMembers.remove(at: index)
                        if membersCount?.memberInvited != nil {
                            membersCount?.memberInvited -= 1
                        }
                    }
                    updateVisibleRequests()
                    isPushedDeclineButton = false
                }
            }
        }
    }
}


