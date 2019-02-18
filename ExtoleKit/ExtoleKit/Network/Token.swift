//Copyright © 2019 Extole. All rights reserved.

import Foundation

func tokenUrl(baseUrl: URL) -> URL {
    return URL.init(string: "/api/v4/token/", relativeTo: baseUrl)!
}

public enum GetTokenError : ExtoleError {
    public static func fromCode(code: String) -> ExtoleError? {
        switch(code) {
            case "invalid_access_token": return GetTokenError.invalidAccessToken
            default: return nil
        }
    }

    public static func toInvalidProtocol(error: ExtoleApiError) -> ExtoleError {
        return GetTokenError.invalidProtocol(error: error)
    }
    case invalidProtocol(error: ExtoleApiError)
    case invalidAccessToken
}

public struct ConsumerToken : Codable {
    init(access_token: String) {
        self.access_token = access_token
    }
    public var accessToken : String {
        get {
            return access_token
        }
    }
    let access_token: String
    let expires_in: Int? = nil
    let scopes: [String]? = nil
    let capabilities: [String]? = nil
}

extension Program {
    public func getToken(success : @escaping (_: ConsumerToken?) -> Void,
                         error: @escaping (_: GetTokenError) -> Void) {
        let request = self.network.getRequest(url: tokenUrl(baseUrl: baseUrl))

        self.network.processRequest(with: request, success: success, error: error)
    }
}
extension ProgramSession {
    
    public func getToken(success : @escaping (_: ConsumerToken?) -> Void,
                         error: @escaping (_: GetTokenError) -> Void) {
        let url = URL.init(string: token.access_token, relativeTo: tokenUrl(baseUrl: baseUrl))!
        let request = self.network.getRequest(url: url)
        self.network.processRequest(with: request, success: success, error: error)
    }
    
    public func deleteToken(success: @escaping ()->Void,
                            error:  @escaping (_: GetTokenError) -> Void) {
        let url = URL.init(string: token.access_token, relativeTo: tokenUrl(baseUrl: baseUrl))!
        let request = self.network.deleteRequest(url: url)
        extoleDebug(format: "deleteToken : %{public}@", arg: url.absoluteString)
        self.network.processNoContentRequest(with: request, success: success, error: error)
    }
}
