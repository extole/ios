//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Me {
    public struct FriendProfileResponse : Decodable {
        let id: String
        let first_name: String?
        let image_url: String?
    }
}
