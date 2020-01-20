//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Zones {
    public struct ZoneResponse : Codable {
        let event_id: String
        let data: [String: String]
    }
}
