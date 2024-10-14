import Foundation
import SwiftUI
import CoreUI
import TurnAPI
import ModalStack

struct MainEturnView: View {
    @Binding var status: EturnStartStatus
    @State private var createTurnVisible = false
    @State private var showEducationalView = false
    @State private var showOrganizationalView = false
    @EnvironmentObject var eturnManager: EturnManager
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var authManager: AuthorizationManager
    @State private var eturnUser: EturnUser?
    @State private var selectedTopTab: Int? = 0
    @State private var selectedBottomTab: Int? = 0
    @State private var searchText: String = ""
    @State private var turnsUploaded = false
    @State private var turnsFirstUploaded = false
    @State private var turnsFoundedByHash = false
    @State private var userUploaded = false
    @State private var finderOpen = false
    @State var turns: [EturnTurn] = []
    public var body: some View {
        ModalStack {
            NavigationView {
                if userUploaded && turnsFirstUploaded {
                    VStack {
                        NavigationLink(destination: CreateTurnView(type: .edu), isActive: $showEducationalView) {
                            EmptyView()
                        }
                        NavigationLink(destination: CreateTurnView(type: .org), isActive: $showOrganizationalView) {
                            EmptyView()
                        }
                        ScrollView {
                            VStack(alignment: .leading) {
                                TitleView(status: $status)
                            }
                            VStack {
                                ProfileUserView(eturnUser: eturnUser)
                            }
                            .padding(.bottom, 10)
                            VStack {
                                ButtonsView(
                                    eturnManager: eturnManager,
                                    turnsUploaded: $turnsUploaded,
                                    turns: $turns
                                )
                            }
                            HStack {
                                SearchPanelView(searchText: $searchText,
                                                turnsUploaded: $turnsUploaded,
                                                turnsFoundedByHash: $turnsFoundedByHash,
                                                turns: $turns,
                                                finderOpen: $finderOpen
                                )
                            }
                            .padding(.top, 15)
                            .padding(.bottom, 5)
                            TurnListView(
                                turns: $turns,
                                turnsUploaded: $turnsUploaded,
                                turnsFoundedByHash: $turnsFoundedByHash,
                                searchText: $searchText
                            )
                        }
                        Spacer()
                        if !finderOpen {
                            Button {
                                Task {
                                    navigationManager.previousScreen = .main
                                    if let eturnUser = eturnManager.getUser() {
                                        if eturnUser.role == "Сотрудник" {
                                            createTurnVisible = true
                                        } else {
                                            showEducationalView = true
                                        }
                                    }
                                }
                            } label: {
                                Text("Создать очередь")
                                    .font(.system(size: 16))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(ColorPalette.primary)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .animation(.easeInOut, value: finderOpen)
                            .padding()
                            .bottomSheet(isPresented: $createTurnVisible, heightDimension: .dynamic) {
                                SelectTurnTypeView(
                                    showEducationalView: $showEducationalView, showOrganizationalView:
                                        $showOrganizationalView, visible: $createTurnVisible)
                            }
                        }
                    }
                    .refreshable {
                        fetchData()
                    }
                    .background(Color.white)
                } else {
                    VStack {
                        SpinnerView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }.background(Color.white)
                }
            }
            .onAppear {
                loadInitialData()
            }
            .onDisappear {
                finderOpen = false
            }
        }
    }
    private func loadInitialData() {
        navigationManager.previousScreen = .main
        if eturnManager.getToken() == nil || authManager.getCurrentProfileID() == nil {
            // TODO: Менять при необходимости для теста
            eturnManager.authorizeTest { result in
                if result {
                    fetchData()
                }
            }
            //status = .authorization
        } else {
            fetchData()
        }
    }
    private func fetchData() {
        if let user = eturnManager.getUser() {
            userUploaded = true
            eturnUser = user
        } else {
            userUploaded = false
            eturnManager.fetchUser { result in
                switch result {
                case .success:
                    userUploaded = true
                    if let user = eturnManager.getUser() {
                        eturnUser = user
                    } else {
                        status = .authorization
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        eturnManager.fetchTurns(
            type: "EDU",
            access: "memberIn"
        ) { fetchedTurns in
            turns = fetchedTurns
            turnsFirstUploaded = true
            turnsUploaded = true
        }
    }
}
