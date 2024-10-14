// swiftlint:disable type_body_length
import Foundation
import Alamofire
// swiftlint:disable type_body_length
public struct LiveEturnAPIClient: EturnAPIClient {
    public func fetchGroups(
        completion: @escaping (Result<[GroupsOfFacultyEturn], any Error>) -> Void
    ) {
        do {
            let request = try EturnAPIRouter.groups.asURLRequest()
            AF.request(request)
                .responseDecodable(of: [GroupsOfFacultyEturn].self) { response in
                    switch response.result {
                    case .success(let groups):
                        completion(.success(groups))
                    case .failure(let error):
                        completion(.failure(EturnAPIClientError.requestFailed(error)))
                    }
                }
        } catch {
            print(error)
        }
    }
    public func deleteTurn(
        hash: String,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    ) {
        do {
            var request = try EturnAPIRouter.deleteTurn(hash: hash).asURLRequest()
            request.headers.add(.authorization(accessToken))
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
        } catch {
            print(error)
        }
    }
    public func authorize(
        authData: EturnAuth,
        completion: @escaping (Result<EturnToken, any Error>) -> Void
    ) {
        do {
            var request = try EturnAPIRouter.auth.asURLRequest()
            request.headers.add(.contentType("application/json"))
            let authJson = try JSONEncoder().encode(authData)
            request.httpBody = authJson
            AF.request(request)
                .responseDecodable(of: EturnToken.self) { response in
                    switch response.result {
                    case .success(let token):
                        completion(.success(token))
                    case .failure(let error):
                        completion(.failure(EturnAPIClientError.requestFailed(error)))
                    }
                }
        } catch {
            print(error)
        }
    }
    public func editTurn(
        with turn: TurnToEdit,
        using token: String,
        completion: @escaping (Result<Bool, any Error>) -> Void
    ) {
        do {
            var request = try EturnAPIRouter.editTurn.asURLRequest()
            request.headers.add(.authorization(token))
            let turnJson = try JSONEncoder().encode(turn)
            request.headers.add(.contentType("application/json"))
            request.httpBody = turnJson
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success:
                        completion(.success(true))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
        } catch {
            print(error)
        }
    }
    public func inviteMember(
        hash: String,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    ) {
        do {
            var request = try EturnAPIRouter.inviteMember(hash: hash).asURLRequest()
            request.headers.add(.authorization(accessToken))
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
        } catch {
            print(error)
        }
    }
    public func changePosition(id: Int, accessToken: String, completion: @escaping (Bool) -> Void) {
        do {
            var request = try EturnAPIRouter.changePosition(id: id).asURLRequest()
            request.headers.add(.authorization(accessToken))
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
        } catch {
            print(error)
        }
    }
    public func skipPosition(
        id: Int,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    ) {
        do {
            var request = try EturnAPIRouter.skipPosition(id: id).asURLRequest()
            request.headers.add(.authorization(accessToken))
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
        } catch {
            print(error)
        }
    }
    public func deletePosition(
        id: Int,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    ) {
        do {
            var request = try EturnAPIRouter.deletePosition(id: id).asURLRequest()
            request.headers.add(.authorization(accessToken))
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
        } catch {
            print(error)
        }
    }
    public func fetchPositions(
        hash: String,
        accessToken: String,
        page: Int,
        completion: @escaping (Result<Positions, any Error>) -> Void
    ) {
        do {
            var request = try EturnAPIRouter.fetchPositions(hash: hash, page: page).asURLRequest()
            request.headers.add(.authorization(accessToken))
            AF.request(request)
                .responseDecodable(of: Positions.self) { response in
                    switch response.result {
                    case .success(let positions):
                        completion(.success(positions))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
        } catch {
            print(error)
        }
    }
    public func createPosition(
        hash: String,
        accessToken: String,
        completion: @escaping (Result<(Any, Int), any Error>) -> Void
    ) {
        do {
            var request = try EturnAPIRouter.createPosition(hash: hash).asURLRequest()
            request.headers.add(.authorization(accessToken))
            AF.request(request)
                .responseDecodable(of: Position.self) { response in
                    if response.data == nil {
                        completion(.success((-1, 200)))
                    } else {
                        switch response.result {
                        case .success(let position):
                            completion(.success((position, 200)))
                        case .failure(let error):
                            if let statusCode = response.response?.statusCode {
                                if statusCode == 400 {
                                    if let data = response.data {
                                        if let stringResponse = String(data: data, encoding: .utf8) {
                                            if let count = Int(stringResponse) {
                                                completion(.success((count, 400)))
                                            }
                                        }
                                    }
                                }
                                completion(.failure(error))
                            }
                        }
                    }
                }
        } catch {
            print(error)
        }
    }
    public func fetchTurnDescription(
        hash: String,
        accessToken: String,
        completion: @escaping (Result<Turn, any Error>) -> Void) {
            do {
                var request = try EturnAPIRouter.fetchTurnDescription(hash: hash).asURLRequest()
                request.headers.add(.authorization(accessToken))
                request.headers.add(.contentType("application/json"))
                AF.request(request)
                    .responseDecodable(of: Turn.self) { response in
                        switch response.result {
                        case .success(let turn):
                            completion(.success(turn))
                        case .failure(let error):
                            completion(.failure(EturnAPIClientError.requestFailed(error)))
                        }
                    }
            } catch {
                print(error)
            }
    }
    public func createTurn(
        with turn: TurnToCreate,
        using token: String,
        completion: @escaping (Result<String, any Error>) -> Void) {
        do {
            var request = try EturnAPIRouter.createTurn.asURLRequest()
            request.headers.add(.authorization(token))
            let turnJson = try JSONEncoder().encode(turn)
            request.headers.add(.contentType("application/json"))
            request.httpBody = turnJson
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success(let data):
                        if let turnHash = String(data: data!, encoding: .utf8) {
                            completion(.success(turnHash))
                        } else {
                            completion(.failure(EturnAPIClientError.invalidResponse))
                        }
                    case .failure(let error):
                        completion(.failure(EturnAPIClientError.requestFailed(error)))
                    }
                }
        } catch {
            print(error)
        }
    }
    public func authorizeTest(completion: @escaping (Result<EturnToken, any Error>) -> Void) {
        do {
            let request = try EturnAPIRouter.authTest.asURLRequest()
            AF.request(request)
                .responseDecodable(of: EturnToken.self) { response in
                    switch response.result {
                    case .success(let token):
                        completion(.success(token))
                    case .failure(let error):
                        completion(.failure(EturnAPIClientError.requestFailed(error)))
                    }
                }
        } catch {
            print(error)
        }
    }
    public init() {}
    public func fetchEturnUser(accessToken: String, completion: @escaping (Result<EturnUser, Error>) -> Void) {
        do {
            var request = try EturnAPIRouter.fetchUserInfo.asURLRequest()
            request.headers.add(.authorization(accessToken))
            AF.request(request)
                .responseDecodable(of: EturnUser.self) { response in
                    switch response.result {
                    case .success(let eturnUser):
                        completion(.success(eturnUser))
                    case .failure(let error):
                        completion(.failure(EturnAPIClientError.requestFailed(error)))
                    }
                }
        } catch {
            print(error)
        }
    }
    public func fetchTurns(
        type: String,
        access: String,
        accessToken: String,
        completion: @escaping (Result<[EturnTurn], Error>) -> Void
    ) {
            do {
                var request = try EturnAPIRouter.fetchTurns(type: type, access: access).asURLRequest()
                request.headers.add(.authorization(accessToken))
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                AF.request(request)
                    .responseDecodable(of: [EturnTurn].self, decoder: decoder) { response in
                        switch response.result {
                        case .success(let turns):
                            completion(.success(turns))
                        case .failure(let error):
                            completion(.failure(EturnAPIClientError.requestFailed(error)))
                        }
                    }
            } catch {
                print(error)
            }
        }
    public func fetchTurnByHash(
            hash: String,
            accessToken: String,
            completion: @escaping (Result<[EturnTurn], Error>) -> Void) {
            do {
                var request = try EturnAPIRouter.fetchTurnByHash(hash: hash).asURLRequest()
                request.headers.add(.authorization(accessToken))
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                AF.request(request)
                    .responseDecodable(of: [EturnTurn].self, decoder: decoder) { response in
                        switch response.result {
                        case .success(let turns):
                            completion(.success(turns))
                        case .failure(let error):
                            completion(.failure(EturnAPIClientError.requestFailed(error)))
                        }
                    }
            } catch {
                completion(.failure(error))
            }
        }
    public func fetchMembers(
        hash: String, 
        type: String,
        page: Int,
        accessToken: String,
        completion: @escaping (Result<MembersResponse, Error>) -> Void) {
            do {
                var request = try EturnAPIRouter.fetchMembers(hash: hash, type: type, page: page).asURLRequest()
                request.headers.add(.authorization(accessToken))
                    AF.request(request)
                        .responseDecodable(of: MembersResponse.self) { response in
                            switch response.result {
                            case .success(let members):
                                completion(.success(members))
                            case .failure(let error):
                                completion(.failure(EturnAPIClientError.requestFailed(error)))
                            }
                        }
                } catch {
                    print(error)
                }
    }
    public func fetchInvited(
        hash: String,
        type: String,
        page: Int,
        accessToken: String,
        completion: @escaping (Result<MembersResponse, Error>) -> Void) {
            do {
                var request = try EturnAPIRouter.fetchInvited(hash: hash, type: type, page: page).asURLRequest()
                request.headers.add(.authorization(accessToken))
                    AF.request(request)
                        .responseDecodable(of: MembersResponse.self) { response in
                            switch response.result {
                            case .success(let members):
                                completion(.success(members))
                            case .failure(let error):
                                completion(.failure(EturnAPIClientError.requestFailed(error)))
                            }
                        }
                } catch {
                    print(error)
                }
    }
    public func acceptMember(
        id: Int,
        status: Bool,
        isModerator: Bool,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    ) {
        do {
            var request = try EturnAPIRouter.acceptMember(id: id, status: status, isModerator: isModerator).asURLRequest()
            request.headers.add(.authorization(accessToken))
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success:
                        completion(true)
                    case .failure(let error):
                        print(error)
                        completion(false)
                    }
                }
        } catch {
            print(error)
        }
    }
    public func editTypeMember(
        id: Int,
        type: String,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    ) {
        do {
            var request = try EturnAPIRouter.editTypeMember(id: id, type: type).asURLRequest()
            request.headers.add(.authorization(accessToken))
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success:
                        completion(true)
                    case .failure(let error):
                        print(error)
                        completion(false)
                    }
                }
        } catch {
            print(error)
        }
    }
    public func deleteMember(
        id: Int,
        accessToken: String,
        completion: @escaping (Bool) -> Void
    ) {
        do {
            var request = try EturnAPIRouter.deleteMember(id: id).asURLRequest()
            request.headers.add(.authorization(accessToken))
            AF.request(request)
                .response { response in
                    switch response.result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
        } catch {
            print(error)
        }
    }

}
