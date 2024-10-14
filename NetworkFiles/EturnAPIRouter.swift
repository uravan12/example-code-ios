import Foundation
import Alamofire

enum EturnAPIRouter: URLRequestConvertible {
    case fetchUserInfo
    case createPosition(hash: String)
    case authTest
    case fetchTurns(type: String, access: String)
    case createTurn
    case fetchTurnDescription(hash: String)
    case fetchTurnByHash(hash: String)
    case deleteTurn(hash: String)
    case fetchPositions(hash: String, page: Int)
    case deletePosition(id: Int)
    case skipPosition(id: Int)
    case changePosition(id: Int)
    case fetchMembers(hash: String, type: String, page: Int)
    case fetchInvited(hash: String, type: String, page: Int)
    case inviteMember(hash: String)
    case editTurn
    case auth
    case acceptMember(id: Int, status: Bool, isModerator: Bool)
    case editTypeMember(id: Int, type: String)
    case deleteMember(id: Int)
    case groups

    var baseURL: URL {
        URL(string: "http://eturn.ru/dev/api")!
    }

    var path: String {
        switch self {
        case .auth:
            return "/auth/etuid"
        case .fetchUserInfo:
            return "/user"
        case .authTest:
            return "/auth/sign-in"
        case .createTurn, .fetchTurns, .editTurn:
            return "/turn"
        case .fetchTurnDescription(let hash):
            return "/turn/"+hash
        case .deleteTurn(let hash):
            return "/turn/"+hash
        case .fetchTurnByHash:
            return "/turn/linked"
        case .createPosition(let hash):
            return "/position/"+hash
        case .deletePosition(let id), .changePosition(let id):
            return "/position/"+String(id)
        case .skipPosition(let id):
            return "/position/skip/"+String(id)
        case .fetchPositions:
            return "/position"
        case .inviteMember:
            return "/member/invite"
        case .fetchMembers:
            return "/member/list"
        case .fetchInvited:
            return "/member/unconfirmed"
        case .acceptMember:
            return "/member/accept"
        case .editTypeMember:
            return "/member"
        case .deleteMember(let id):
            return "/member/"+String(id)
        case .groups:
            return "/groups"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchUserInfo, .fetchTurns, .fetchTurnDescription, .fetchTurnByHash, .fetchPositions, .fetchMembers, .fetchInvited, .groups:
            return .get
        case .authTest, .createTurn, .createPosition, .auth:
            return .post
        case .deletePosition, .deleteMember, .deleteTurn:
            return .delete
        case .changePosition, .skipPosition, .inviteMember, .acceptMember, .editTurn, .editTypeMember:
            return .put
        }
    }
    var parameters: [String: String]? {
        switch self {
        case .fetchTurns(let type, let access):
            return ["type": type, "access": access]
        case .authTest:
            return ["login": "vue", "password": "vue"]
        case .fetchTurnByHash(let hash):
            return ["hash": hash]
        case .fetchPositions(let hash, let page):
            return ["hash": hash, "page": String(page)]
        case .inviteMember(let hash):
            return ["hash": hash]
        case .fetchMembers(let hash, let type, let page):
            return ["hash": hash, "type": type, "page": String(page)]
        case .fetchInvited(let hash, let type, let page):
            return ["hash": hash, "type": type, "page": String(page)]
        case .acceptMember(let id, let status, let isModerator):
            return ["id": String(id), "status": String(status), "isModerator": String(isModerator)]
        case .editTypeMember(let id, let type):
            return ["id": String(id), "type": type]
        default:
            return nil
        }
    }
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = try URLRequest(url: url, method: method)
        switch self {
        case .authTest, .fetchTurns, .fetchTurnByHash, .fetchPositions, .inviteMember, .fetchMembers, .fetchInvited, .acceptMember, .editTypeMember:
            if let parameters = parameters {
                request = try URLEncodedFormParameterEncoder.default.encode(parameters, into: request)
            }
        default:
            break
        }
        return request
    }
}
