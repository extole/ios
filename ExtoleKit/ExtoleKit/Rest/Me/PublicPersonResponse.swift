//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Me {
    public struct PublicPersonResponse : Decodable {
        let id: String
        let first_name: String?
        let image_url: String?
        let parameters: [String: String]
    }
}
