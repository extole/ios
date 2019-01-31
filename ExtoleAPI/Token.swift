//
//  Token.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation


enum ExtoleApiError {
    case serverError(error: Error)
    case decodingError
    case noContent
    case genericError(errorData: ErrorData)
}

enum VerifyTokenError : Error {
    case invalidProtocol(error: ExtoleApiError)
    case invalidAccessToken
}

public struct ConsumerToken : Codable {
    let access_token: String
    let expires_in: Int
    let scopes: [String]
    let capabilities: [String]
}

extension Program {

    public func getToken() -> APIResponse<ConsumerToken> {
        let url = URL(string: "\(baseUrl)/api/v4/token")!
        return dataTask(url: url, accessToken: nil, postData: nil)
    }
    
    public func verifyToken(token: String, callback : @escaping (_: ConsumerToken?, _: VerifyTokenError?) -> Void) {
        
        let url = URL(string: "\(baseUrl)/api/v4/token/\(token)")!
        let request = newRequest(url: url)
       
        processRequest(with: request) { data, error in
            if let apiError = error {
                switch(apiError) {
                    case .genericError(let errorData) : do {
                        switch(errorData.code) {
                            case "invalid_access_token": callback(nil, .invalidAccessToken)
                            default:  callback(nil, .invalidProtocol(error: .genericError(errorData: errorData)))
                        }
                    }
                    default : callback(nil, .invalidProtocol(error: apiError))
                }
                return
            }
            if let data = data {
                let decodedToken : ConsumerToken? = tryDecode(data: data)
                if let token = decodedToken {
                    callback(token, nil)
                } else {
                    callback(nil, .invalidProtocol(error: .decodingError))
                }
            }
            
        }
       
    }
}

