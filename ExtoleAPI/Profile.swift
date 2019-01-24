//
//  Profile.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public struct MyProfile : Codable {
    let email: String
    let first_name: String
    let last_name: String
    let partner_user_id: String
}

public struct SuccessResponse : Codable {
    let status: String
}
extension Program {

    public func updateProfile(accessToken: ConsumerToken, profile: MyProfile)
        -> APIResponse<SuccessResponse> {
            let url = URL(string: "\(baseUrl)/api/v4/me")!
            let shareableData = try? JSONEncoder().encode(profile)
            return dataTask(url: url, accessToken: accessToken.access_token, postData: shareableData)
    }

    public func getProfile(accessToken: ConsumerToken)
        -> APIResponse<MyProfile> {
            let url = URL(string: "\(baseUrl)/api/v4/me")!
            return dataTask(url: url, accessToken: accessToken.access_token, postData: nil)
    }
}
