//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Events {
    public struct SubmitEventRequest : Codable {
        let event_name: String
        let data: [String: String];
    }
}
