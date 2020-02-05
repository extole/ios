//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Me {
    public struct MeShareableResponse: Decodable {
        public let code: String?
        public let key: String?
        public let label: String?
        public let link: String?
        public let data:  [String: String]
        public let content: ExtoleAPI.Me.ShareableContent?
    }
}
