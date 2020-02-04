//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Me {
    public struct MeDataBulkUpdateRequest: Encodable {
        let type: String
        let parameters: [String: String]
    }
}
