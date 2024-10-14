import Foundation
import SwiftUI
import CoreUI
import TurnAPI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct SearchPanelView: View {
    @Binding var searchText: String
    @EnvironmentObject var eturnManager: EturnManager
    @Binding var turnsUploaded: Bool
    @Binding var turnsFoundedByHash: Bool
    @Binding var turns: [EturnTurn]
    @Binding var finderOpen: Bool
    @FocusState private var focusedOnField
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("", text: $searchText)
                    .placeholder(when: searchText.isEmpty) {
                        Text("Поиск")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                    }
                    .foregroundColor(.black)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity)
                    .onChange(of: searchText) { newSearchText in
                        handleSearchTextChange(newSearchText: newSearchText)
                    }
                    .onReceive(searchText.publisher.collect()) { characters in
                        let maxCharacters = 64
                        if characters.count > maxCharacters {
                            searchText = String(characters.prefix(maxCharacters))
                        }
                    }
                    .focused($focusedOnField)
            }
            .onChange(of: focusedOnField) { newValue in
                if !newValue {
                    finderOpen = false
                }
            }
            .onTapGesture {
                focusedOnField = true
                finderOpen = true
            }
//            .onAppear {
//                finderOpen = false
//            }
            .onDisappear {
                focusedOnField = false
            }
            .padding()
            .background(ColorPalette.gray238)
            .cornerRadius(12)
            .padding(.horizontal, 22)
            Text("Если у вас есть код очереди – вставьте его в поиск")
                .font(.system(size: 12))
                .foregroundColor(ColorPalette.gray149)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(0)
                .padding(.horizontal, 22)
        }
    }
    private func handleSearchTextChange(newSearchText: String) {
        if newSearchText.hasPrefix("Code:") && newSearchText.count == 11 {
            searchTurnByHash(newSearchText: newSearchText)
        } else if newSearchText.isEmpty ||
                    !newSearchText.hasPrefix("Code:") ||
                    newSearchText.count != 11 {
            fetchTurnsBySearch()
        }
    }
    private func searchTurnByHash(newSearchText: String) {
        let hash = String(newSearchText.dropFirst(5))
        if hash.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil {
            turnsUploaded = false
            eturnManager.fetchTurnByHash(
                hash: hash
            ) { result in
                switch result {
                case .success(let foundTurns):
                    self.turns = foundTurns
                    self.turnsFoundedByHash = true
                    turnsUploaded = true
                case .failure:
                    turnsUploaded = true
                    self.turns = []
                }
            }
        } else {
        }
    }
    private func fetchTurnsBySearch() {
        turnsFoundedByHash = false
        eturnManager.fetchTurns(
            type: "EDU",
            access: "memberIn"
        ) { fetchedTurns in
            turns = fetchedTurns
        }
    }
}
