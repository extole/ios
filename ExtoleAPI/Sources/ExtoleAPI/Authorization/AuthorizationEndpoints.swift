//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    public enum Authorization {}
}

extension ExtoleAPI.Authorization {
    public struct CreateSessionError {
        public enum Code :String {
            case jwt_error
            case invalid_email
            case email_mismatch
            case invalid_access_token_duration
        }
        public let error: ExtoleAPI.Error
        
        var code: Code? {
            get {
                return Code.init(rawValue: error.code)
            }
        }
    }
    
    public struct ResumeSessionError {
        public enum Code :String {
            case missing_access_token
            case invalid_access_token
            case expired_access_token
            case access_denied
        }
        public let error: ExtoleAPI.Error
        
        public var code: Code? {
            get {
                return Code.init(rawValue: error.code)
            }
        }
    }
}

extension ExtoleAPI {
    var tokenUrl: URL {
        get {
             return URL.init(string: "/api/v5/token/", relativeTo: baseUrl)!
        }
    }
    
    public func createSession(email: String? = nil,
                                jwt: String? = nil,
                                duration_seconds: Int64? = nil,
                                success : @escaping (_: ExtoleAPI.Session) -> Void,
                                error: @escaping (_: ExtoleAPI.Authorization.CreateSessionError) -> Void) {
        
        let tokenRequest = Authorization.CreateTokenRequest(email: email,
                                                            jwt: jwt,
                                                            duration_seconds: duration_seconds)
        
        let request = self.network.newJsonRequest(method: "POST",
                                                       url: tokenUrl,
                                                       headers: [:],
                                                       data: tokenRequest)

         self.network.processRequest(with: request, success: {token in
             success(ExtoleAPI.Session(extoleAPI: self, token: token))
         }, error: { e in
            error(ExtoleAPI.Authorization.CreateSessionError.init(error: e))
         })
         
    }

    public func resumeSession(accessToken: String,
                       success : @escaping (_: ExtoleAPI.Session) -> Void,
                       error: @escaping (_: ExtoleAPI.Authorization.ResumeSessionError) -> Void) {
         let empty : String? = nil
         let authorizationHeader = [ "Authorization": accessToken]
         let request = self.network.newJsonRequest(method: "GET", url: tokenUrl, headers: authorizationHeader, data: empty)
         self.network.processRequest(with: request, success: { token in
            success(ExtoleAPI.Session(extoleAPI: self, token: token))
         }, error: { e in
            error(ExtoleAPI.Authorization.ResumeSessionError.init(error: e))
         })
    }
}

extension ExtoleAPI.Session {
    
    public func verify(success : @escaping (_: ExtoleAPI.Authorization.TokenResponse) -> Void,
                               error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let request = self.getRequest(url: self.extoleAPI.tokenUrl)
        self.network.processRequest(with: request, success: success, error: error)
    }

    public func invalidate(success: @escaping ()->Void,
                           error:  @escaping (_: ExtoleAPI.Error) -> Void) {
        let request = self.deleteRequest(url: self.extoleAPI.tokenUrl)
        self.network.processNoContentRequest(with: request, success: success, error: error)
    }
}

extension ExtoleAPI.Error {
    public func isInvalidAccessToken() -> Bool {
        return code == "invalid_access_token"
    }
    public func isMissingAccessToken() -> Bool {
        return code == "missing_access_token"
    }
    public func isExpiredAccessToken() -> Bool {
        return code == "expired_access_token"
    }
    public func isInvalidProgramDomain() -> Bool {
        return code == "invalid_program_domain"
    }
}

