public enum EturnAPIClientError: Error {
    case requestFailed(Error)
    case invalidResponse
}

public protocol EturnAPIClient {
    func createTurn(
        with turn: TurnToCreate,
        using token: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
    func editTurn(
        with turn: TurnToEdit,
        using token: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
    func fetchEturnUser(
        accessToken: String,
        completion: @escaping (Result<EturnUser, Error>) -> Void
    )
    func authorizeTest(
        completion: @escaping(Result<EturnToken, Error>) -> Void
    )
    func authorize(
        authData: EturnAuth,
        completion: @escaping(Result<EturnToken, Error>) -> Void
    )
    func fetchTurns(
        type: String,
        access: String,
        accessToken: String,
        completion: @escaping (Result<[EturnTurn], Error>) -> Void
    )
    func fetchTurnByHash(
        hash: String,
        accessToken: String,
        completion: @escaping (Result<[EturnTurn], Error>) -> Void
    )
    func fetchTurnDescription(
        hash: String,
        accessToken: String,
        completion: @escaping (Result<Turn, Error>) -> Void
    )
    func createPosition(
        hash: String,
        accessToken: String,
        completion: @escaping (Result<(Any, Int), Error>) -> Void
    )
    func fetchPositions(
        hash: String,
        accessToken: String,
        page: Int,
        completion: @escaping (Result<Positions, Error>) -> Void
    )
    func fetchGroups(
        completion: @escaping (Result<[GroupsOfFacultyEturn], Error>) -> Void
    )
    func deletePosition(
        id: Int,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    )
    func changePosition(
        id: Int,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    )
    func skipPosition(
        id: Int,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    )
    func fetchMembers(
        hash: String,
        type: String,
        page: Int,
        accessToken: String,
        completion: @escaping (Result<MembersResponse, Error>) -> Void
    )
    func fetchInvited(
        hash: String,
        type: String,
        page: Int,
        accessToken: String,
        completion: @escaping (Result<MembersResponse, Error>) -> Void
    )
    func inviteMember(
        hash: String,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    )
    func deleteTurn(
        hash: String,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    )
    func acceptMember(
        id: Int,
        status: Bool,
        isModerator: Bool,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    )
    func editTypeMember(
        id: Int,
        type: String,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    )
    func deleteMember(
        id: Int,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    )
}
