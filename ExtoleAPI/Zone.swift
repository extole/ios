//
//  Zone.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation
import os.log

extension Program {
    
    enum GetObjectError : Error {
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

    public func fetchZone(accessToken: String?, zone: String) -> APIResponse<Data> {
        let url = URL(string: "\(baseUrl)/zone/\(zone)")!
        return contentTask(url: url, accessToken: accessToken)
    }
    
    func contentTask(url: URL, accessToken: String?) -> APIResponse<Data> {
        let apiResponse = APIResponse<Data>.init()
        os_log("requesting %s", log: NetworkLog, type: .debug, url.absoluteString)
        let newSession = URLSession.init(configuration: URLSessionConfiguration.ephemeral)
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("*/*", forHTTPHeaderField: "Accept")
        if let existingToken = accessToken {
            os_log("using accessToken %s", log: NetworkLog, type: .debug, existingToken)
            urlRequest.addValue(existingToken, forHTTPHeaderField: "Authorization")
        }
        let task = newSession.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                apiResponse.setError(error: ExtoleError.networkError(error: error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    if let responseData = data {
                        let decodedError: ErrorData? = tryDecode(data: responseData)
                        if let decodedError = decodedError {
                            apiResponse.setError(error: ExtoleError.serverError(errorData: decodedError))
                        } else {
                            apiResponse.setError(error: ExtoleError.encodingError)
                        }
                    } else {
                        apiResponse.setError(error: ExtoleError.noContent)
                    }
                    return
            }
            if let responseData = data {
                apiResponse.setData(data: responseData)
            } else {
                apiResponse.setError(error: ExtoleError.noContent)
            }
            
        }
        task.resume()
        return apiResponse
    }
}
