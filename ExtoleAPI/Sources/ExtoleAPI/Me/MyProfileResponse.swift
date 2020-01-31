//Copyright © 2019 Extole. All rights reserved.

import Foundation
extension ExtoleAPI.Me {
    public struct MyProfileResponse: Decodable {
        let id: String
        let email: String?
        let first_name: String?
        let last_name: String?
        let profile_picture_url: String?
        let partner_user_id: String?
        let parameters: [String: String]
        let cookie_consent: String?
        let cookie_consent_type: String?
        let processing_consent: String?;
        let processing_consent_type: String?;
        let locale: String?;
    }
}
