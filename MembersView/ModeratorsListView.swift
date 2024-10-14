import Foundation
import SwiftUI
import TurnAPI
import CoreUI

struct ModeratorsListView: View {
    var turnHash: String
    @EnvironmentObject var eturnManager: EturnManager
    @Binding var moderators: [EturnMember]
    @Binding var membersCount: MembersCount?
    var updateMembers: () -> Void
    @Binding var status: String?
    @State private var buttonStates: [Int: Bool] = [:]
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(moderators, id: \.id) { member in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(member.userName) \(member.group)")
                                    .padding(.trailing, 10)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .padding(0)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .padding(.bottom, status != nil && status != "CREATOR" ? 7 : 0)
                            if status != nil && status == "CREATOR" {
                                Button {
                                    Task {
                                        buttonStates[member.id] = true
                                        editType(id: member.id, type: "MEMBER")
                                    }
                                } label: {
                                    if buttonStates[member.id] ?? false {
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
                                .padding(.horizontal, 10)
                            }
                        }
                    }
        }
        .padding(.top, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        if moderators.isEmpty {
            HStack {
                Spacer()
                Text("Назначьте модераторов для помощи в управлении очередью")
                    .font(.system(size: 16))
                    .foregroundStyle(.black)
                    .padding(.vertical)
                Spacer()
            }
        }
    }
    func editType(id: Int, type: String) {
        eturnManager.editType(id: id, type: type) { result in
            if result {
                if let index = moderators.firstIndex(where: { $0.id == id }) {
                    moderators.remove(at: index)
                    updateMembers()
                }
                buttonStates[id] = false
            } else {
            }
        }
    }
}
