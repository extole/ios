//Copyright © 2019 Extole. All rights reserved.

import Foundation

public struct MobileSharing: Codable {
    struct Data: Codable{
        let me: [String: String]
    }
    let event_id: String
    let data: Data
}
