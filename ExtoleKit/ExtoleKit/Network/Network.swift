//
//  Network.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

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
        extoleDebug(format: "using accessToken %{private}@", arg: existingToken.access_token)
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
    return jsonRequest(method: "POST", accessToken: accessToken, url: url, data: data)
}

func putRequest<T : Encodable>(accessToken: ConsumerToken? = nil, url: URL, data: T) -> URLRequest {
    return jsonRequest(method: "PUT", accessToken: accessToken, url: url, data: data)
}

func jsonRequest<T : Encodable>(method: String, accessToken: ConsumerToken? = nil, url: URL, data: T) -> URLRequest {
    var result = URLRequest(url: url)
    extoleDebug(format: "url %{public}@", arg: url.absoluteString)
    extoleDebug(format: "method %{public}@", arg: method)
    result.httpMethod = method
    result.addValue("application/json", forHTTPHeaderField: "Content-Type")
    result.httpBody =  try? JSONEncoder().encode(data)
    if let existingToken = accessToken {
        extoleDebug(format: "using accessToken %{private}@", arg: existingToken.access_token)
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
            extoleDebug(format: "processRequest : %{public}@", arg: responseDataString)
            callback(responseData, nil)
        } else {
            callback(nil, .noContent)
        }
    }
    task.resume()
}
    
func dataTask<T: Decodable> (url: URL, accessToken: String?, postData: Data?) -> APIResponse<T> {
    let apiResponse = APIResponse<T>.init()
    let newSession = URLSession.init(configuration: URLSessionConfiguration.ephemeral)
    var urlRequest = URLRequest(url: url)
    if let existingToken = accessToken {
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
