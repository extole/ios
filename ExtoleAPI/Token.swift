//
//  Token.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

extension Program {
    public func getToken() -> APIResponse<ConsumerToken> {
        let url = URL(string: "\(baseUrl)/api/v4/token")!
        return dataTask(url: url, accessToken: nil, postData: nil)
    }
}
public struct ConsumerToken : Codable {
    let access_token: String
    let expires_in: Int
    let scopes: [String]
    let capabilities: [String]
}
