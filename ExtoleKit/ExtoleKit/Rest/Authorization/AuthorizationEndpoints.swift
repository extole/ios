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
    public func createSession(accessToken: String? = nil,
                               tokenRequest: Authorization.CreateTokenRequest? = nil,
                               success : @escaping (_: ExtoleAPI.Session) -> Void,
                               error: @escaping (_: ExtoleAPI.Error) -> Void) {
         if let existingAccessToken = accessToken {
             resumeSession(accessToken: existingAccessToken, success: success, error: error)
         } else {
             let request = self.network.newJsonRequest(method: "POST",
                                                       url: v5TokenUrl,
                                                       headers: [:],
                                                       data: tokenRequest)

             self.network.processRequest(with: request, success: {token in
                 success(ExtoleAPI.Session(extoleAPI: self, token: token))
             }, error: error)
         }
    }

    func resumeSession(accessToken: String,
                              success : @escaping (_: ExtoleAPI.Session) -> Void,
                              error: @escaping (_: ExtoleAPI.Error) -> Void) {
         let empty : String? = nil
         let authorizationHeader = [ "Authorization": accessToken]
         let request = self.network.newJsonRequest(method: "GET", url: v5TokenUrl, headers: authorizationHeader, data: empty)
         self.network.processRequest(with: request, success: { token in
             success(ExtoleAPI.Session(extoleAPI: self, token: token))
         }, error: error)
    }
}

extension ExtoleAPI.Session {
    
    public func verify(success : @escaping (_: ExtoleAPI.Authorization.TokenResponse) -> Void,
                               error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let request = self.getRequest(url: self.extoleAPI.v5TokenUrl)
        self.network.processRequest(with: request, success: success, error: error)
    }

    public func invalidate(success: @escaping ()->Void,
                           error:  @escaping (_: ExtoleAPI.Error) -> Void) {
        let request = self.deleteRequest(url: self.extoleAPI.v5TokenUrl)
        self.network.processNoContentRequest(with: request, success: success, error: error)
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

