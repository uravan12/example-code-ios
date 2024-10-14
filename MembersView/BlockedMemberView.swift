import Foundation
import SwiftUI
import TurnAPI
import CoreUI

struct BlockedMemberView: View {
    @EnvironmentObject var eturnManager: EturnManager
    var blockedMember: EturnMember
    @Binding var membersCount: MembersCount?
    @Binding var blockedMembers: [EturnMember]
    @State private var isPushed = false
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                Text("\(blockedMember.userName) \(blockedMember.group)")
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
                    unlockMember(id: blockedMember.id, type: "MEMBER")
                } label: {
                    if isPushed {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: ColorPalette.yellow155))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .frame(width: 40, height: 40, alignment: .topLeading)
                    } else {
                        Image(.Eturn.unlockButton)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(ColorPalette.yellow155)
                            .padding(.horizontal, 5)
                            .frame(width: 40, height: 40, alignment: .topLeading)
                    }
                }
                .padding(.trailing, 10)
            }
        }
    }
    func unlockMember(id: Int, type: String) {
        eturnManager.editType(id: id , type: type) { result in
            if result {
                if let index = blockedMembers.firstIndex(where: { $0.id == id }) {
                    let removedMember = blockedMembers.remove(at: index)
                    if membersCount?.blocked != nil {
                        membersCount?.blocked -= 1
                    }
                }
                isPushed = false
            }
        }
    }
}



