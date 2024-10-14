import Foundation
import SwiftUI
import CoreUI
import TurnAPI

struct ProfileUserView: View {
    var eturnUser: EturnUser?
    func getGroup(user: EturnUser) -> String {
        if let group = user.group {
            return "\(user.role), гр. \(group)"
        } else {
            return user.role
        }
    }
    var body: some View {
        VStack {
            if let user = eturnUser {
                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.system(size: 22))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .padding(.bottom, 0.2)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(getGroup(user: user))
                        .font(.system(size: 16))
                        .fontWeight(.light)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(15)
                .background(Color.white)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .shadow(color: .black.opacity(0.1), radius: 5)
            }
        }
        .padding(.horizontal, 22)
    }
}
