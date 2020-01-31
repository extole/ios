//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Authorization {
    public struct CreateTokenRequest: Codable {
        let email: String?
        let jwt: String?
        let duration_seconds: Int64?
    }
}
