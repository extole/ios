//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Me {
    public struct PersonProfileUpdateRequest: Encodable {
        let email: String?
        let first_name: String?
        let last_name: String?
        let profile_picture_url: String?
        let partner_user_id: String?
    }
}
