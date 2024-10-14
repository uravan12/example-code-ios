import Foundation
import SwiftUI
import CoreUI

struct TitleView: View {
    @EnvironmentObject var authManager: AuthorizationManager
    @EnvironmentObject var eturnManager: EturnManager
    @Binding var status: EturnStartStatus
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Главная")
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                    .foregroundStyle(ColorPalette.primary)
                Spacer()
                Text("Cписок очередей")
                    .font(.system(size: 16))
                    .foregroundStyle(ColorPalette.gray121)
                Spacer()
            }
            Spacer()
            Button {
                Task {
                    authManager.signOut()
                    eturnManager.clearProfileData()
                    status = .authorization
                }
            } label: {
                Image(.Eturn.exitButton)
                    .font(.title2)
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 10)
    }
}
