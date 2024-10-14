import Foundation
import SwiftUI
import TurnAPI
import CoreUI

struct MemberShowView: View {
    @EnvironmentObject var eturnManager: EturnManager
    var member: EturnMember
    @Binding var membersCount: MembersCount?
    @Binding var members: [EturnMember]
    @State private var isPushed = false
    var updateBlocked: () -> Void
    var updateModerRequests: () -> Void
    var body: some View {
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
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
            HStack {
                Button {
                    isPushed = true
                    banMember(id: member.id, type: "BLOCKED")
                } label: {
                    if isPushed {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: ColorPalette.red155))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .frame(width: 40, height: 40, alignment: .topLeading)
                    } else {
                        Image(.Eturn.cancelButton)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(ColorPalette.red155)
                            .padding(.horizontal, 5)
                            .frame(width: 40, height: 40, alignment: .topLeading)
                    }
                }
                .padding(.trailing, 10)
            }
        }
    }
    func banMember(id: Int, type: String) {
        eturnManager.editType(id: id , type: type) { result in
            if result {
                if let index = members.firstIndex(where: { $0.id == id }) {
                    let removedMember = members.remove(at: index)
                    updateBlocked()
                    updateModerRequests()
                    if membersCount?.member != nil {
                        membersCount?.member -= 1
                        membersCount?.blocked += 1
                    }
                }
                isPushed = false
            }
        }
    }
}




