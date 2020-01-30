//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Share {
    public struct EmailShareRequest: Encodable {
        let preferred_code_prefixes : [String]?
        let key: String?
        let labels: String?
        let campaign_id: String?

        let recipient_email: String;
        let message: String;
        let subject: String;
        let data: [String: String];
    }
}
