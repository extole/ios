//
//  EmailShare.swift
//  ExtoleKit
//
//  Created by rtibin on 2/12/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public struct EmailShare : Codable {
    public init(advocate_code: String, recipient_email: String? = nil,
         message: String? = nil,
         subject: String? = nil,
         data: [String:String]? = nil) {
        self.advocate_code = advocate_code
        self.subject = subject
        self.message = message
        self.recipient_email = recipient_email
        self.data = data
    }
    let advocate_code: String
    let message: String?
    let subject: String?
    let recipient_email: String?
    let data: [String:String]?
}

public enum EmailShareError : Error {
    case invalidProtocol(error: ExtoleApiError)
}

public enum PollEmailShareError : Error {
    case invalidProtocol(error: ExtoleApiError)
    case pollingTimeout
}

public struct EmailSharePollingResult : Codable {
    let polling_id : String
    let status : String
    let share_id : String
}

extension ProgramSession {
    
    public func emailShare(share: EmailShare, callback : @escaping (PollingIdResponse?, EmailShareError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/email/share")!
        let request = postRequest(accessToken: token,
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

    public func pollEmailShare(pollingResponse: PollingIdResponse,
                                callback : @escaping (EmailSharePollingResult?, PollEmailShareError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/email/share/status/\(pollingResponse.polling_id)")!
        let request = getRequest(accessToken: token,
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
                    let decodedResponse : EmailSharePollingResult? = tryDecode(data: data)
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
