import Foundation
import SwiftUI
import TurnAPI
import CoreUI

struct JoinRequestsMembersView: View {
    @EnvironmentObject var eturnManager: EturnManager
    @Binding var requestMembers: [EturnMember]
    @Binding var moderators: [EturnMember]
    @Binding var members: [EturnMember]
    @Binding var membersCount: MembersCount?
    var turnHash: String
    @State private var visibleRequestMembers: [EturnMember] = []
    @State private var page = 0
    @Binding var isLoading: Bool
    @State private var hasReachedEnd = false
    @State var targetVisibleCount: Int = 0
    @State var hasHalfRequestsPassed: Int = 0
    var body: some View {
        Group {
            if requestMembers.isEmpty {
                HStack {
                    Spacer()
                    Text("Новых заявок нет")
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.vertical, 50)
            } else {
                VStack {
                    ForEach(visibleRequestMembers.indices, id: \.self) { index in
                        if let lastIndex = visibleRequestMembers.indices.last {
                            JoinRequestsMemberView(
                                requestMember: requestMembers[index],
                                membersCount: $membersCount,
                                requestMembers: $requestMembers,
                                members: $members,
                                visibleRequestMembers: $visibleRequestMembers,
                                updateVisibleRequests: updateVisibleRequests
                            )
                            .opacity(visibleRequestMembers.count <= 10
                                     ? (index == 0 ? 1.0 : 0.5)
                                     : (index == 0 ? 1.0 : (index <= 9 ? 0.5 : (index == 10 ? 0.2 : 0.05))) )
                            .disabled(index != 0)
                        }
                    }
                    if isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                        .padding(.horizontal)
                )
                .padding(.top, 15)
            }
        }
        .onAppear {
            fetchJoinRequests()
        }
        .onChange(of: requestMembers.count) { newCount in
            if newCount == hasHalfRequestsPassed {
                fetchJoinRequestsWithoutDublicates()
            }
        }
    }
    func updateTargetVisibleCount() {
        
        if membersCount?.memberInvited ?? 0 > 12 {
            targetVisibleCount = 12
            hasHalfRequestsPassed = requestMembers.count % 2 == 0
                                ? requestMembers.count / 2 + 5
                                : Int(ceil(Double(requestMembers.count) / 2.0))
        } else {
            targetVisibleCount = requestMembers.count
        }
    }
    private func updateVisibleRequests() {
        visibleRequestMembers = Array(requestMembers.prefix(targetVisibleCount))
    }
    func fetchJoinRequests() {
        eturnManager.fetchInvited(hash: turnHash, type: "MEMBER", page: 0) { result in
            switch result {
            case .success(let fetchedInvitedMembers):
                self.requestMembers = fetchedInvitedMembers.list
                membersCount?.memberInvited = fetchedInvitedMembers.count
                isLoading = false
                updateTargetVisibleCount()
                updateVisibleRequests()
                print("visible: \(visibleRequestMembers)")
                print("JoinRequests: \(requestMembers)")
            case .failure(let error):
                print("Error fetching \(error)")
                isLoading = false
            }
        }
    }
    func fetchJoinRequestsWithoutDublicates() {
        eturnManager.fetchInvited(hash: turnHash, type: "MEMBER", page: 0) { result in
            switch result {
            case .success(let fetchedInvitedMembers):
                let newMembers = fetchedInvitedMembers.list.filter { newMember in
                     !self.requestMembers.contains { existingMember in
                     newMember.id == existingMember.id
                   }
               }
                membersCount?.memberInvited = fetchedInvitedMembers.count
                self.requestMembers.append(contentsOf: newMembers)
                print("SUCCESS!1!: \(requestMembers)")
            case .failure(let error):
                print("Error fetching: \(error)")
            }
        }
    }
}
