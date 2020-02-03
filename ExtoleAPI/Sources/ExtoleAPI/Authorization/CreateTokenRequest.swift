//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Authorization {
    public struct CreateTokenRequest: Codable {
        let email: String?
        let jwt: String?
        let duration_seconds: Int64?
        
        public init(email: String? = nil, jwt: String? = nil, duration_seconds: Int64? = nil) {
            self.email = email;
            self.jwt = jwt;
            self.duration_seconds = duration_seconds;
        }
    }
}
