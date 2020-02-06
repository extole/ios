//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Share {
    public struct EmailShareResponse : Decodable {
        public let recipient_email: String
        public let polling_id: String
    }
}
