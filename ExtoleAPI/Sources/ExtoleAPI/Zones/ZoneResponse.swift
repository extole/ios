//Copyright © 2019 Extole. All rights reserved.

import Foundation
extension ExtoleAPI.Zones {
    public struct ZoneResponse : Decodable {
        public let event_id: String
        public let data: Json
    }
}
