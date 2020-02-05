//Copyright © 2019 Extole. All rights reserved.

import Foundation
extension ExtoleAPI.Zones {
    public struct ZoneResponse : Decodable {
        let event_id: String
        let data: Json
    }
}
