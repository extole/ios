//Copyright © 2019 Extole. All rights reserved.

import Foundation
extension ExtoleAPI.Me {

    public struct ShareResponse: Decodable {
        public let recipients : [String]
        public let recipient_email : String
        public let friend : ExtoleAPI.Person.PublicPersonResponse
        public let data:  [String: String]
    }
}
