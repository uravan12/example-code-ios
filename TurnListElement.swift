import Foundation
import SwiftUI
import TurnAPI
import CoreUI
struct TurnListElement: View {
    @Binding var turn: EturnTurn
    @State private var isTurnViewPresented = false
    var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(turn.name)
                            .font(.system(size: 22))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .padding(0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if turn.description != nil {
                            Text(turn.description!)
                                .font(.system(size: 16))
                                .fontWeight(.light)
                                .padding(0)
                                .padding(.top, 3)
                                .foregroundColor(.black)
                                .lineLimit(3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text(formattedDateRange(start: turn.dateStart, end: turn.dateEnd))
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .padding(0)
                                    .padding(.top, 5)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(0)
                    .padding(.bottom, 12)
                    .padding(.top, 3)
                    .padding(.horizontal, 15)
                    if turn.accessMember == "CREATOR" || turn.accessMember == "MODERATOR" {
                        Image(systemName: "star.fill")
                            .foregroundColor(ColorPalette.primary)
                            .padding(.trailing, 15)
                            .padding(.top, 8)
                    }
                }
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                )
                .padding(.top, 5)
            }
            .background(
                        NavigationLink(destination: TurnView(turnHash: turn.id), isActive: $isTurnViewPresented) {
                            EmptyView()
                        }
                        .buttonStyle(PlainButtonStyle())
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isTurnViewPresented = true
                    }
    }
    private func formattedDateRange(start: String, end: String) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

            guard let startDate = formatter.date(from: start),
                  let endDate = formatter.date(from: end) else {
                return "Дата и время недоступны"
            }

            formatter.dateFormat = "dd.MM HH:mm"
            let formattedStart = formatter.string(from: startDate)
            let formattedEnd = formatter.string(from: endDate)

            return "С \(formattedStart) до \(formattedEnd)"
        }}
