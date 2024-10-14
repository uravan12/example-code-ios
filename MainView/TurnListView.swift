import Foundation
import SwiftUI
import CoreUI
import TurnAPI
import ModalStack

struct TurnListView: View {
    @EnvironmentObject var eturnManager: EturnManager
    @Binding var turns: [EturnTurn]
    @Binding var turnsUploaded: Bool
    @Binding var turnsFoundedByHash: Bool
    @Binding var searchText: String
    var body: some View {
        VStack(spacing: 10) {
            if !turnsUploaded {
                SpinnerView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.top, 20)
            } else if turns.isEmpty {
                Text("Очереди не найдены")
                    .foregroundColor(ColorPalette.primary)
                    .padding(30)
            } else if !turnsFoundedByHash {
                if $turns.filter({ $turn in
                    searchText.isEmpty ||
                    isTurnMatchingSearch(turn: turn, searchText: searchText)}).isEmpty {
                    Text("Очереди не найдены")
                        .foregroundColor(ColorPalette.primary)
                        .padding(30)
                } else {
                    ForEach($turns.filter { $turn in
                        searchText.isEmpty ||
                        isTurnMatchingSearch(turn: turn, searchText: searchText)
                    }) { $turn in
                        TurnListElement(turn: $turn)
                    }
                }
            } else {
                ForEach($turns) { $turn in
                    TurnListElement(turn: $turn)
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 30)
    }

    func isTurnMatchingSearch(turn: EturnTurn, searchText: String) -> Bool {
        let searchTerms = searchText.lowercased().components(separatedBy: " ")
        let turnTags = turn.tags.lowercased().components(separatedBy: " ")

        for searchTerm in searchTerms {
            var isMatch = false
            for tag in turnTags {
                if tag.contains(searchTerm) {
                    isMatch = true
                    break
                } else if Int(searchTerm) != nil && Int(tag) != nil {
                    if searchTerm == tag {
                        isMatch = true
                        break
                    }
                } else if Int(searchTerm) == nil && Int(tag) == nil && editDistance(searchTerm, tag) <= 2 {
                    isMatch = true
                    break
                }
            }
            if !isMatch {
                return false
            }
        }
        return true
    }

    private func editDistance(_ str1: String, _ str2: String) -> Int {
        let len1 = str1.count
        let len2 = str2.count
        var matrix = Array(repeating: Array(repeating: 0, count: len2 + 1), count: len1 + 1)
        for index in 0...len1 {
            matrix[index][0] = index
        }
        for jitex in 0...len2 {
            matrix[0][jitex] = jitex
        }
        if str1.isEmpty { return str2.count }
        if str2.isEmpty { return str1.count }
        for index in 1...len1 {
            for jitex in 1...len2 {
                let cost = str1[str1.index(str1.startIndex, offsetBy: index - 1)]
                == str2[str2.index(str2.startIndex, offsetBy: jitex - 1)]
                ? 0 : 1
                matrix[index][jitex] = min(
                    matrix[index - 1][jitex] + 1,
                    matrix[index][jitex - 1] + 1,
                    matrix[index - 1][jitex - 1] + cost
                )
            }
        }
        return matrix[len1][len2]
    }
}
