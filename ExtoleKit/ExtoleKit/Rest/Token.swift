//Copyright © 2019 Extole. All rights reserved.

import Foundation

func tokenV4Url(baseUrl: URL) -> URL {
    return URL.init(string: "/api/v4/token/", relativeTo: baseUrl)!
}
func tokenV5Url(baseUrl: URL) -> URL {
    return URL.init(string: "/api/v4/token/", relativeTo: baseUrl)!
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

public struct CreateTokenRequest: Codable {
    let email: String? = nil
}

extension ExtoleAPI {
    public func createToken(success : @escaping (_: ConsumerToken) -> Void,
                         error: @escaping (_: ExtoleError) -> Void) {
        let request = self.network.newJsonRequest(method: "POST", url: tokenV5Url(baseUrl: baseUrl), headers: [:], data: CreateTokenRequest())

        self.network.processRequest(with: request, success: success, error: error)
    }
}

extension ConsumerSession {
    
    public func verifyToken(success : @escaping (_: ConsumerToken) -> Void,
                         error: @escaping (_: ExtoleError) -> Void) {
        let url = URL.init(string: token.access_token, relativeTo: tokenV4Url(baseUrl: baseUrl))!
        let request = self.getRequest(url: url)
        self.network.processRequest(with: request, success: success, error: error)
    }
    
    public func deleteToken(success: @escaping ()->Void,
                            error:  @escaping (_: ExtoleError) -> Void) {
        let url = URL.init(string: token.access_token, relativeTo: tokenV4Url(baseUrl: baseUrl))!
        let request = self.deleteRequest(url: url)
        extoleDebug(format: "deleteToken : %{public}@", arg: url.absoluteString)
        self.network.processNoContentRequest(with: request, success: success, error: error)
    }
}


extension ExtoleError {
    func isInvalidAccessToken() -> Bool {
        return code == "invalid_access_token"
    }
    func isMissingAccessToken() -> Bool {
        return code == "missing_access_token"
    }
    func isExpiredAccessToken() -> Bool {
        return code == "expired_access_token"
    }
    func isInvalidProgramDomain() -> Bool {
        return code == "invalid_program_domain"
    }
}
