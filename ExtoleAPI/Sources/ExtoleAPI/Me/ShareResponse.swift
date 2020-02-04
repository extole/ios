//Copyright © 2019 Extole. All rights reserved.

import Foundation
extension ExtoleAPI.Me {

    public struct ShareResponse: Decodable {
        let recipients : [String]
        let recipient_email : String
        let friend : ExtoleAPI.Person.PublicPersonResponse
        let data:  [String: String]
    }
}
