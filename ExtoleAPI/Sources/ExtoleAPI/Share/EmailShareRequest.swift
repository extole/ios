//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Share {
    public struct EmailShareRequest: Encodable {
        public let recipient_email: String
        public let message: String
        public let subject: String
        public let data: [String: String]
        
        public let preferred_code_prefixes : [String]?
        public let key: String?
        public let labels: String?
        public let campaign_id: String?
    }
}
