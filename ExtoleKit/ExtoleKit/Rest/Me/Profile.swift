//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public final class MyProfile : NSObject, Codable {
    public init(email: String? = nil, partner_user_id: String? = nil,
         first_name:String? = nil, last_name:String? = nil) {
        self.email = email
        self.partner_user_id = partner_user_id
        self.first_name = first_name
        self.last_name = last_name
    }
    public let email: String?
    public let first_name: String?
    public let last_name: String?
    public let partner_user_id: String?
}

public struct SuccessResponse : Codable {
    let status: String
}

extension ExtoleAPI.Session {
    
    public func updateProfile(profile: MyProfile,
                              success: @escaping () -> Void,
                              error : @escaping (ExtoleAPI.Error) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v4/me")!
        let request = self.postRequest(url: url,
                                 data: profile)
        self.network.processNoContentRequest(with: request, success: success, error: error)
    }

    public func getProfile(success: @escaping (MyProfile) -> Void,
                           error: @escaping (ExtoleAPI.Error) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v4/me")!
        let request = self.getRequest(url: url)
        self.network.processRequest(with: request, success: success, error: error)
        
    }
}
