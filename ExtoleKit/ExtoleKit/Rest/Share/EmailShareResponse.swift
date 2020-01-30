//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Share {
    public struct EmailShareResponse : Decodable {
        let recipient_email: String
        let polling_id: String
    }
}
