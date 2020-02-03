//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Me {
    public struct ShareableContent: Codable {
        let partner_content_id: String?
        let title: String?
        let image_url: String?
        let description: String?
        let url: String?
    }
}
