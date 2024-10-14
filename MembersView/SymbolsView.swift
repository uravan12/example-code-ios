import Foundation
import SwiftUI
import CoreUI
struct SymbolsView: View {
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Условные обозначения")
                .font(.system(size: 24))
                .fontWeight(.bold)
                .foregroundStyle(.black)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                    .frame(width: 350, height: 200)
                ZStack {
                    VStack(alignment: .leading) {
                        HStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(ColorPalette.green200)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(.Eturn.acceptMember)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(5)
                                )
                                .padding(.horizontal, 10)
                            Text("Подтвердить и сделать обычным участником")
                                .font(.system(size: 18))
                        }
                        .padding(.top, 5)
                        HStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(ColorPalette.blue177)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(.Eturn.increaseRole)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(5)
                                )
                                .padding(.horizontal, 10)
                            Text("Сделать модератором")
                                .font(.system(size: 18))
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .padding(.top, 20)
    }
}
