//
//  Profile.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public struct MyProfile : Codable {
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

public enum GetProfileError : Error {
    case invalidProtocol(error: ExtoleApiError)
}


public enum UpdateProfileError : Error {
    case invalidProtocol(error: ExtoleApiError)
    case invalidPersonEmail
}

extension Program {

    public func identify(accessToken: ConsumerToken, email: String,
                         callback : @escaping (UpdateProfileError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v4/me")!
        let request = postRequest(accessToken: accessToken,
                                  url: url,
                                  data: MyProfile.init(email: email))
        processRequest(with: request) { data, error in
            if let apiError = error {
                switch(apiError) {
                case .genericError(let errorData) : do {
                    switch(errorData.code) {
                    case "invalid_person_email": callback(.invalidPersonEmail)
                    default:  callback(.invalidProtocol(error: .genericError(errorData: errorData)))
                    }
                    }
                default : callback(.invalidProtocol(error: apiError))
                }
                return
            }
            callback(nil)
        }
    }
    
    public func updateProfile(accessToken: ConsumerToken, profile: MyProfile,
                              callback : @escaping (UpdateProfileError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v4/me")!
        let request = postRequest(accessToken: accessToken,
                                 url: url,
                                 data: profile)
        processRequest(with: request) { data, error in
            if let apiError = error {
                switch(apiError) {
                case .genericError(let errorData) : do {
                    callback(.invalidProtocol(error: .genericError(errorData: errorData)))
                    }
                default : callback(.invalidProtocol(error: apiError))
                }
                return
            }
            callback(nil)
        }
    }

    public func getProfile(accessToken: ConsumerToken,
                           callback : @escaping (MyProfile?, GetProfileError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v4/me")!
        let request = getRequest(accessToken: accessToken,
                                  url: url)
        processRequest(with: request) { data, error in
            if let apiError = error {
                switch(apiError) {
                case .genericError(let errorData) : do {
                    callback(nil, .invalidProtocol(error: .genericError(errorData: errorData)))
                    }
                default : callback(nil, .invalidProtocol(error: apiError))
                }
                return
            }
            if let data = data {
                let decodedProfile : MyProfile? = tryDecode(data: data)
                if let decodedProfile = decodedProfile {
                    callback(decodedProfile, nil)
                } else {
                    callback(nil, .invalidProtocol(error: .decodingError(data: data)))
                }
            }
        }
    }
}
