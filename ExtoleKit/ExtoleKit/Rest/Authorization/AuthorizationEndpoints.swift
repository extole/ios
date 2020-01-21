//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    public enum Authorization {}
}



extension ExtoleAPI {
    var v5TokenUrl: URL {
        get {
             return URL.init(string: "/api/v5/token/", relativeTo: baseUrl)!
        }
    }
    
    public func createSession(tokenRequest: Authorization.CreateTokenRequest? = nil,
                               success : @escaping (_: ExtoleAPI.Session) -> Void,
                               error: @escaping (_: ExtoleAPI.Error) -> Void) {
         let request = self.network.newJsonRequest(method: "POST", url: v5TokenUrl, headers: [:], data: tokenRequest)

         self.network.processRequest(with: request, success: {token in
             success(ExtoleAPI.Session(program: self, token: token))
         }, error: error)
    }

    public func resumeSession(accessToken: String,
                              success : @escaping (_: ExtoleAPI.Session) -> Void,
                              error: @escaping (_: ExtoleAPI.Error) -> Void) {
         let url = URL.init(string: accessToken, relativeTo: v5TokenUrl)!
         let empty : String? = nil
         let request = self.network.newJsonRequest(method: "GET", url: url, headers: [:], data: empty)
         self.network.processRequest(with: request, success: { token in
             success(ExtoleAPI.Session(program: self, token: token))
         }, error: error)
    }
}

extension ExtoleAPI.Error {
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

