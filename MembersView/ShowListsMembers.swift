import Foundation
import SwiftUI
import TurnAPI
import CoreUI

struct ShowListsMembers: View {
    var turnHash: String
    @Binding var membersCount: Int?
    @Binding var selectedList: SelectedList
    @Binding var visible: Bool
    @EnvironmentObject var eturnManager: EturnManager
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(getTitle(for: selectedList))
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                if let count = membersCount {
                    if count != 0 {
                        Circle()
                            .fill(ColorPalette.primary)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text(count > 99 ? "99" : String(count))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            )
                    }
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .rotationEffect(.degrees(visible ? 180 : 0), anchor: .center)
                    .animation(.easeInOut(duration: 0.2), value: visible)
                    .padding(.trailing, 16)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        visible.toggle()
                    }
                
            }
        }
        .padding(.top, 30)
        .padding(.horizontal)
    }
    func getTitle(for selectedList: SelectedList) -> String {
        switch selectedList {
        case .members:
            return "Участники"
        case .moderatorRequests:
            return "Заявки на модератора"
        case .joinRequests:
            return "Заявки на вступление"
        case .blocked:
            return "Заблокированные"
        }
    }
}
