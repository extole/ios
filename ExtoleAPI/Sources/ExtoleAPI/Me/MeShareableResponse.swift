//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Me {
    public struct MeShareableResponse: Decodable {
        let code: String?
        let key: String?
        let label: String?
        let link: String?
        let data:  [String: String]
        let content: ExtoleAPI.Me.ShareableContent?
    }
}
