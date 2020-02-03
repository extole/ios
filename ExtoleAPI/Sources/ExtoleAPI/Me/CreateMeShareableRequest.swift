//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Me {
    struct CreateMeShareableRequest: Encodable {
        let preferred_code_prefixes: [String]?
        let key: String?
        let label: String?
        let content: ExtoleAPI.Me.ShareableContent?
        let data: [String:String]
    }
    
}
