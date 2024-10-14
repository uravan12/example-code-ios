// swiftlint:disable type_body_length
import Foundation
import TurnAPI
import KeychainService

final class EturnManager: ObservableObject {
    private let eturnAPIClient: EturnAPIClient
    private let keychainService: KeychainService
    @Published public var turns: [EturnTurn] = []
    init(eturnAPIClient: EturnAPIClient, keychainService: KeychainService) {
        self.eturnAPIClient = eturnAPIClient
        self.keychainService = keychainService
    }
    // MARK: - authoriztaion methods
    func getToken() -> EturnToken? {
        return keychainService.read(account: "eturn_token", type: EturnToken.self)
    }
    private func saveToken(token: EturnToken) {
        keychainService.save(token, account: "eturn_token")
    }
    func getUser() -> EturnUser? {
        return keychainService.read(account: "eturn_profile", type: EturnUser.self)
    }
    private func saveUserProfile(user: EturnUser) {
        keychainService.save(user, account: "eturn_profile")
    }
    func clearProfileData() {
        keychainService.delete(account: "eturn_profile")
        keychainService.delete(account: "eturn_token")
    }
    // MARK: - http requests
    public func fetchPositions(
        hash: String,
        page: Int,
        completion: @escaping (Result<Positions, Error>) -> Void
    ) {
        if let token = getToken() {
            eturnAPIClient.fetchPositions(
                hash: hash,
                accessToken: token.token,
                page: page
            ) { result in
                switch result {
                case .success(let positions):
                    completion(.success(positions))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    public func fetchGroups(completion: @escaping (Result<[GroupsOfFacultyEturn], Error>) -> Void) {
        eturnAPIClient.fetchGroups { result in
            switch result {
            case .success(let groups):
                completion(.success(groups))
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    public func deleteTurn(
        hash: String,
        completion: @escaping (Bool) -> Void
    ) {
        if let token = getToken() {
            eturnAPIClient.deleteTurn(
                hash: hash,
                accessToken: token.token
            ) { result in
                    completion(result)
            }
        }
    }
    public func deletePosition(
        id: Int,
        completion: @escaping (Bool) -> Void
    ) {
        if let token = getToken() {
            eturnAPIClient.deletePosition(
                id: id,
                accessToken: token.token
            ) { result in
                completion(result)
            }
        }
    }
    public func inviteMember(
        hash: String,
        completion: @escaping (Bool) -> Void
    ) {
        if let token = getToken() {
            eturnAPIClient.inviteMember(
                hash: hash,
                accessToken: token.token
            ) { result in
                completion(result)
            }
        }
    }
    public func changePosition(
        id: Int,
        completion: @escaping (Bool) -> Void
    ) {
        if let token = getToken() {
            eturnAPIClient.changePosition(
                id: id,
                accessToken: token.token
            ) { result in
                completion(result)
            }
        }
    }
    public func skipPosition(
        id: Int,
        completion: @escaping (Bool) -> Void
    ) {
        if let token = getToken() {
            eturnAPIClient.skipPosition(
                id: id,
                accessToken: token.token
            ) { result in
                completion(result)
            }
        }
    }
    public func fetchTurnDescription(
        hash: String,
        completion: @escaping (Result<Turn, Error>) -> Void
    ) {
        if let token = getToken() {
            eturnAPIClient.fetchTurnDescription(
                hash: hash,
                accessToken: token.token
            ) { result in
                switch result {
                case .success(let turn):
                    completion(.success(turn))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    public func createPosition(
        hash: String,
        completion: @escaping (Result<(Any, Int), Error>) -> Void
    ) {
        if let token = getToken() {
            eturnAPIClient.createPosition(
                hash: hash,
                accessToken: token.token
            ) { result in
                switch result {
                case .success(let position):
                    completion(.success(position))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    // TODO: Убрать, когда не будет надобности
    public func authorizeTest(completion: @escaping (Bool) -> Void) {
        eturnAPIClient.authorizeTest { result in
            switch result {
            case .success(let token):
                self.saveToken(token: token)
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    public func authorize(
        auth: EturnAuth,
        completion: @escaping (Bool) -> Void
    ) {
        eturnAPIClient.authorize(authData: auth) { result in
            switch result {
            case .success(let token):
                self.saveToken(token: token)
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    public func fetchUser(
        completion: @escaping (Result<EturnUser, Error>) -> Void
    ) {
        if let token = getToken() {
            eturnAPIClient.fetchEturnUser(accessToken: token.token) { result in
                do {
                    let user = try result.get()
                    self.saveUserProfile(user: user)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                    print(error)
                }
            }
        }
    }
    public func editTurn(
        turnDTO: TurnCreateDTO,
        hash: String,
        completion: @escaping (Bool) -> Void
    ) {
        if let token = getToken() {
            let timers = [0, 1, 2, 3, 4, 5, 10, 15]
            let positionsCount = [-1, 0, 5, 10, 25, 30, 35, 40]
            let description = turnDTO.description == "" ? nil : turnDTO.description
            let turn = TurnAPI.TurnToEdit(
                hash: hash,
                allowedGroups: turnDTO.selectedGroup,
                allowedFaculties: turnDTO.selectedFaculty,
                name: turnDTO.name,
                description: description,
                timer: timers[turnDTO.selectedTimer],
                positionCount: positionsCount[turnDTO.selectedRate])
            eturnAPIClient.editTurn(with: turn, using: token.token) { result in
                switch result {
                case .success:
                    return completion(true)
                case .failure:
                    return completion(false)
                }
            }
        }
    }
    public func createTurn(turnDTO: TurnCreateDTO, completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let token = getToken()?.token else {return}
        let timers = [0, 1, 2, 3, 4, 5, 10, 15]
        let positionsCount = [-1, 0, 5, 10, 25, 30, 35, 40]
        let access: TurnAccess = turnDTO.selectedAccessType == 0 ? .forLink : .forAllowedElements
        let description = turnDTO.description == "" ? nil : turnDTO.description
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let date = turnDTO.selectedDateStart < Date() ? Date() : turnDTO.selectedDateStart
        let dateStart = dateFormatter.string(from: date)
        let dateEnd = dateFormatter.string(from: turnDTO.selectedDateEnd)
        let groups = turnDTO.selectedAccessType == 1 ? turnDTO.selectedGroup : []
        let faculties = turnDTO.selectedAccessType == 2 ? turnDTO.selectedFaculty : []
        let turn = TurnAPI.TurnToCreate(
            name: turnDTO.name,
            description: description,
            turnType: turnDTO.type,
            timer: timers[turnDTO.selectedTimer],
            positionCount: positionsCount[turnDTO.selectedRate],
            turnAccess: access,
            allowedGroups: groups,
            allowedFaculties: faculties,
            dateStart: dateStart,
            dateEnd: dateEnd
        )
        eturnAPIClient.createTurn(with: turn, using: token) { result in
            do {
                let turnHash = try result.get()
                completion(.success(turnHash))
            } catch {
                completion(.failure(error))
            }
        }
    }
    public func fetchTurns(
        type: String,
        access: String,
        completion: @escaping ([EturnTurn]) -> Void
    ) {
        if let token = getToken() {
            eturnAPIClient.fetchTurns(
                type: type,
                access: access,
                accessToken: token.token) { result in
                    do {
                        let turns = try result.get()
                        completion(turns)
                    } catch {
                        completion([])
                    }
                }
        }
    }
    public func fetchTurnByHash(
        hash: String,
        completion: @escaping (Result<[EturnTurn], Error>) -> Void
    ) {
        if let token = getToken() {
            eturnAPIClient.fetchTurnByHash(hash: hash, accessToken: token.token, completion: completion)
        }
    }
        public func fetchMembers(
            hash: String,
            type: String,
            page: Int,
            completion: @escaping (Result<MembersResponse, Error>) -> Void
        ) {
            if let token = getToken() {
                eturnAPIClient.fetchMembers(hash: hash, type: type, page: page, accessToken: token.token) { result in
                    switch result {
                    case .success(let members):
                        completion(.success(members))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
        public func fetchInvited(
            hash: String,
            type: String,
            page: Int,
            completion: @escaping (Result<MembersResponse, Error>) -> Void
        ) {
            if let token = getToken() {
                eturnAPIClient.fetchInvited(hash: hash, type: type, page: page, accessToken: token.token) { result in
                    switch result {
                    case .success(let members):
                        completion(.success(members))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
        public func acceptMember(
            id: Int,
            status: Bool,
            isModerator: Bool,
            completion: @escaping (Bool) -> Void
        ) {
            if let token = getToken() {
                eturnAPIClient.acceptMember(
                    id: id,
                    status: status,
                    isModerator: isModerator,
                    accessToken: token.token
                ) { result in
                    if result {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
        public func editType(
            id: Int,
            type: String,
            completion: @escaping (Bool) -> Void
        ) {
            if let token = getToken() {
                eturnAPIClient.editTypeMember(
                    id: id,
                    type: type,
                    accessToken: token.token
                ) { result in
                    if result {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
    public func deleteMember(
        id: Int,
        completion: @escaping (Bool) -> Void
    ) {
        if let token = getToken() {
            eturnAPIClient.deleteMember(
                id: id,
                accessToken: token.token
            ) { result in
                completion(result)
            }
        }
    }
}
