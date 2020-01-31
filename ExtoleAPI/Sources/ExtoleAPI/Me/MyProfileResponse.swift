//Copyright © 2019 Extole. All rights reserved.

import Foundation
extension ExtoleAPI.Me {
    public struct MyProfileResponse: Decodable {
        public let id: String
        public let email: String?
        public let first_name: String?
        public let last_name: String?
        public let profile_picture_url: String?
        public let partner_user_id: String?
        public let parameters: [String: String]
        public let cookie_consent: String?
        public let cookie_consent_type: String?
        public let processing_consent: String?;
        public let processing_consent_type: String?;
        public let locale: String?;
    }
}
