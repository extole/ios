//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Zones {
    public struct RenderZoneRequest : Codable {
        let event_name: String
        let data: [String: String];
    }
}
