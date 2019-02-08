//
//  Zone.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

extension Program {
    
    public enum GetObjectError : Error {
        case invalidProtocol(error: ExtoleApiError)
    }
    
    public func fetchObject<T: Codable>(accessToken: ConsumerToken, zone: String,
                            callback : @escaping (T?, GetObjectError?) -> Void) {
        let url = URL(string: "\(baseUrl)/zone/\(zone)")!
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
                let decodedData : T? = tryDecode(data: data)
                if let decodedData = decodedData {
                    callback(decodedData, nil)
                } else {
                    callback(nil, .invalidProtocol(error: .decodingError(data: data)))
                }
            }
        }
    }
}
