import Foundation
import SwiftUI
import CoreUI
import TurnAPI

struct ShowModalMembersView: View {
    var textLabels: [String]
    @Binding var isSelected: SelectedList
    @Binding var sheetVisible: Bool
    @Binding var membersCount: MembersCount?

    public var body: some View {
        VStack(alignment: .leading) {
            Text("Список участников")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.bottom, 5)

            ForEach(0..<textLabels.count, id: \.self) { index in
                let item = textLabels[index]
                HStack {
                    Text(item).foregroundColor(.black)
                    switch SelectedList(rawValue: index) {
                        case .members:
                            if var count = membersCount?.member, count > 0 {
                                ZStack {
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
                        case .moderatorRequests:
                            if let count = membersCount?.moderatorInvited, count > 0 {
                                ZStack {
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
                        case .joinRequests:
                            if let count = membersCount?.memberInvited, count > 0 {
                                ZStack {
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
                        case .blocked:
                            if let count = membersCount?.blocked, count > 0 {
                                ZStack {
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
                        default:
                            EmptyView()
                        }
                    Spacer()
                    if isSelected == SelectedList(rawValue: index) {
                        Image(systemName: "circle.fill")
                            .foregroundColor(ColorPalette.primary)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(ColorPalette.primary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isSelected = SelectedList(rawValue: index)!
                    sheetVisible.toggle()
                }
                .padding(.bottom, 15)
            }
        }
        .background(.white)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
