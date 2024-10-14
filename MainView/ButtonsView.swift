import Foundation
import SwiftUI
import CoreUI
import TurnAPI

struct RightAngledRectangle: Shape { // для выравнивания закругления кнопок
    let radius: CGFloat
    let roundedCorners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let uiBezierPath = UIBezierPath(roundedRect: rect, byRoundingCorners: roundedCorners,
                                        cornerRadii: CGSize(width: radius, height: radius))
        uiBezierPath.close()
        return Path(uiBezierPath.cgPath)
    }
}

struct ButtonsView: View {
    @ObservedObject var eturnManager: EturnManager
    @State private var selectedTopTab: Int? = 0
    @State private var selectedBottomTab: Int? = 0
    @State var valueType = "EDU"
    @State var valueState = "memberIn"
    @Binding var turnsUploaded: Bool
    @Binding var turns: [EturnTurn]
    var body: some View {
        HStack(spacing: 0) {
            Button {
                Task {
                    turnsUploaded = false
                    selectedTopTab = 0
                    fetchTurnsForButton(type: "EDU", access: valueState)
                    valueType = "EDU"
                }
            } label: {
                Text("Учебные")
                    .frame(height: 45)
                    .frame(maxWidth: .infinity)
                    .background(selectedTopTab == 0 ? ColorPalette.primary : ColorPalette.gray242)
                    .foregroundColor(selectedTopTab == 0 ? .white : .black)
            }
            .clipShape(RightAngledRectangle(radius: 10, roundedCorners: [.topLeft, .bottomLeft]))
            Button {
                Task {
                    turnsUploaded = false
                    selectedTopTab = 1
                    fetchTurnsForButton(type: "ORG", access: valueState)
                    valueType = "ORG"
                }
            } label: {
                Text("Организационные")
                    .frame(height: 45)
                    .frame(maxWidth: .infinity)
                    .background(selectedTopTab == 1 ? ColorPalette.primary : ColorPalette.gray242)
                    .foregroundColor(selectedTopTab == 1 ? .white : .black)
            }
            .clipShape(RightAngledRectangle(radius: 10, roundedCorners: [.topRight, .bottomRight]))
        }
        .padding(.horizontal, 22)
        .cornerRadius(8)
        .onAppear {
            selectedTopTab = 0
        }

        HStack(spacing: 0) {
            Button {
                Task { turnsUploaded = false
                    selectedBottomTab = 0
                    fetchTurnsForButton(type: valueType, access: "memberIn")
                    valueState = "memberIn"
                }
            } label: {
                Text("Мои")
                    .frame(height: 45)
                    .frame(maxWidth: .infinity)
                    .background(selectedBottomTab == 0 ? ColorPalette.primary : ColorPalette.gray242)
                    .foregroundColor(selectedBottomTab == 0 ? .white : .black)
            }
            .clipShape(RightAngledRectangle(radius: 10, roundedCorners: [.topLeft, .bottomLeft]))
            Button {
                Task { turnsUploaded = false
                    selectedBottomTab = 1
                    fetchTurnsForButton(type: valueType, access: "memberOut")
                    valueState = "memberOut"
                }
            } label: {
                Text("Доступные")
                    .frame(height: 45)
                    .frame(maxWidth: .infinity)
                    .background(selectedBottomTab == 1 ? ColorPalette.primary : ColorPalette.gray242)
                    .foregroundColor(selectedBottomTab == 1 ? .white : .black)
            }
            .clipShape(RightAngledRectangle(radius: 10, roundedCorners: [.topRight, .bottomRight]))
        }
        .padding(.horizontal, 22)
        .cornerRadius(8)
        .padding(.top, 5)
        .onAppear {
            valueType = "EDU"
            valueState = "memberIn"
            selectedTopTab = 0
            selectedBottomTab = 0
            turnsUploaded = false
            fetchTurnsForButton(type: "EDU", access: "memberIn")
        }
    }
    func fetchTurnsForButton(type: String, access: String) {
        eturnManager.fetchTurns(type: type, access: access) {fetchedTurns in
            self.turns = fetchedTurns
            turnsUploaded = true
        }
    }
}
