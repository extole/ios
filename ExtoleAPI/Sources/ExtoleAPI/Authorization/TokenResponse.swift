//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Authorization {
    public struct TokenResponse : Codable {
        let access_token: String
        let expires_in: Int64
        let scopes: [String]
    }
}
