//
//  Network.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation
import os.log

@available(iOS 10.0, *)
let NetworkLog = OSLog.init(subsystem: "com.extole", category: "network")

func tryDecode<T: Codable>(data: Data) -> T? {
    let decoder = JSONDecoder.init()
    return try? decoder.decode(T.self, from: data)
}

func newSession() -> URLSession {
    return URLSession.init(configuration: URLSessionConfiguration.ephemeral)
}

func getRequest(accessToken: ConsumerToken? = nil, url: URL) -> URLRequest {
    var result = URLRequest(url: url)
    if let existingToken = accessToken {
        if #available(iOS 10.0, *) {
            os_log("using accessToken %{private}@", log: NetworkLog, type: .debug, existingToken.access_token)
        } else {
            // Fallback on earlier versions
        }
        result.addValue(existingToken.access_token, forHTTPHeaderField: "Authorization")
    }
    return result
}

func newRequest(url: URL, method: String) -> URLRequest {
    var result = URLRequest(url: url)
    result.httpMethod = method
    return result
}

func postRequest<T : Encodable>(accessToken: ConsumerToken? = nil, url: URL, data: T) -> URLRequest {
    var result = URLRequest(url: url)
    result.httpMethod = "POST"
    result.addValue("application/json", forHTTPHeaderField: "Content-Type")
    result.httpBody =  try? JSONEncoder().encode(data)
    if let existingToken = accessToken {
        if #available(iOS 10.0, *) {
            os_log("using accessToken %{private}@", log: NetworkLog, type: .debug, existingToken.access_token)
        } else {
            // Fallback on earlier versions
        }
        result.addValue(existingToken.access_token, forHTTPHeaderField: "Authorization")
    }
    return result
}

func processRequest(with request: URLRequest,
                    callback:  @escaping (_: Data?, _: ExtoleApiError?) -> Void) {
    let session = newSession()
    let task = session.dataTask(with: request) { data, response, error in
        if let serverError = error {
            callback(nil, ExtoleApiError.serverError(error: serverError))
        }
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                if let responseData = data {
                    let decodedError: ErrorData? = tryDecode(data: responseData)
                    if let decodedError = decodedError {
                        callback(nil, .genericError(errorData: decodedError))
                    } else {
                        callback(nil, .decodingError(data: responseData))
                    }
                } else {
                    callback(nil, .noContent)
                }
                return
        }
        if let responseData = data {
            let responseDataString = String(data: responseData, encoding: .utf8)!
            if #available(iOS 10.0, *) {
                os_log("processRequest : %{public}@", log: NetworkLog, type: OSLogType.debug, responseDataString)
            } else {
                // Fallback on earlier versions
            }
            callback(responseData, nil)
        } else {
            callback(nil, .noContent)
        }
    }
    task.resume()
}
    
func dataTask<T: Decodable> (url: URL, accessToken: String?, postData: Data?) -> APIResponse<T> {
    let apiResponse = APIResponse<T>.init()
    if #available(iOS 10.0, *) {
        os_log("dataTask %s", log: NetworkLog, type: .debug, url.absoluteString)
    } else {
        // Fallback on earlier versions
    }
    let newSession = URLSession.init(configuration: URLSessionConfiguration.ephemeral)
    var urlRequest = URLRequest(url: url)
    if let existingToken = accessToken {
        if #available(iOS 10.0, *) {
            os_log("using accessToken %s", log: NetworkLog, type: .debug, existingToken)
        } else {
            // Fallback on earlier versions
        }
        urlRequest.addValue(existingToken, forHTTPHeaderField: "Authorization")
    }
    if let postData = postData {
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = postData
    }
    let task = newSession.dataTask(with: urlRequest) { data, response, error in
        // Logger.Debug(message: "dataTask.response with data: \(data), reponse: \(response), error: \(error)")
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
            if #available(iOS 10.0, *) {
                os_log("reponseData :%s", log: .default, type: .debug, String(data: responseData, encoding: String.Encoding.utf8)!)
            } else {
                // Fallback on earlier versions
            }
            let decodedData: T? = tryDecode(data: responseData)
            if let decodedData = decodedData {
                apiResponse.setData(data: decodedData)
            } else {
                apiResponse.setError(error: ExtoleError.encodingError)
            }
        } else {
            apiResponse.setError(error: ExtoleError.noContent)
        }
        
    }
    task.resume()
    return apiResponse
}
