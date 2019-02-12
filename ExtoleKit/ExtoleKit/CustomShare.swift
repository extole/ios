//
//  CustomShare.swift
//  ExtoleKit
//
//  Created by rtibin on 2/12/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation
public struct CustomShare : Codable {
    init(advocate_code: String, channel: String, message : String? = nil, recipient_email: String? = nil,
         data: [String:String]? = nil) {
        self.advocate_code = advocate_code
        self.channel = channel
        self.message = message
        self.recipient_email = recipient_email
        self.data = data
    }
    let advocate_code: String
    let channel: String
    let message: String?
    let recipient_email: String?
    let data: [String:String]?
}

public enum CustomShareError : Error {
    case invalidProtocol(error: ExtoleApiError)
}

public enum PollShareError : Error {
    case invalidProtocol(error: ExtoleApiError)
    case pollingTimeout
}

public struct CustomSharePollingResult : Codable {
    let polling_id : String
    let status : String
    let share_id : String
}

extension Program {
    
    public func customShare(accessToken: ConsumerToken, share: CustomShare, callback : @escaping (PollingIdResponse?, CustomShareError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/custom/share")!
        let request = postRequest(accessToken: accessToken,
                                  url: url,
                                  data: share)
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
                let decodedResponse : PollingIdResponse? = tryDecode(data: data)
                if let decodedResponse = decodedResponse {
                    callback(decodedResponse, nil)
                } else {
                    callback(nil, .invalidProtocol(error: .decodingError(data: data)))
                }
            }
        }
    }
    
    public func pollCustomShare(accessToken: ConsumerToken, pollingResponse: PollingIdResponse,
                                callback : @escaping (CustomSharePollingResult?, PollShareError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/custom/share/status/\(pollingResponse.polling_id)")!
        let request = getRequest(accessToken: accessToken,
                                 url: url)
        
        func poll(retries: UInt = 10) {
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
                    let decodedResponse : CustomSharePollingResult? = tryDecode(data: data)
                    if let decodedResponse = decodedResponse {
                        let pollingStatus = decodedResponse.status
                        if pollingStatus == "SUCCEEDED" {
                            callback(decodedResponse, nil)
                        } else if retries > 0 {
                            sleep(1)
                            poll(retries: retries - 1)
                        } else {
                            callback(nil, .pollingTimeout)
                        }
                    } else {
                        callback(nil, .invalidProtocol(error: .decodingError(data: data)))
                    }
                }
            }
        }
        poll(retries: 10)
    }
    
}
