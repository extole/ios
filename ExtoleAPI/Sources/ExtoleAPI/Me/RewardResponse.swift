//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Me {
    public class RewardResponse: Decodable {
        let reward_id: String
        let state: String
        let partner_reward_id: String
        let reward_code: String
        let face_value: String
        let face_value_type: String
        let date_earned: String
        let date_issued: String
        let date_delivered: String
        let campaign_id: String
        let program_label: String
        let sandbox: String?
        let slots: [String]
        let tags: [String]
        let reward_type: String
        let reward_supplier_id: String?
        let partner_reward_supplier_id: String?
    }
}
