//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {

    public class Authorization {
       
        
        public struct CreateTokenRequest: Codable {
            let email: String? = nil
        }
        
        public struct ConsumerToken : Codable {
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
