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

func newRequest(url: URL) -> URLRequest {
    return URLRequest(url: url)
}
    
func dataTask<T: Decodable> (url: URL, accessToken: String?, postData: Data?) -> APIResponse<T> {
    let apiResponse = APIResponse<T>.init()
    Logger.Info(message: "dataTask with \(url)")
    let newSession = URLSession.init(configuration: URLSessionConfiguration.ephemeral)
    var urlRequest = URLRequest(url: url)
    if let existingToken = accessToken {
        Logger.Info(message: "using accessToken \(existingToken)")
        urlRequest.addValue(existingToken, forHTTPHeaderField: "Authorization")
    }
    if let postData = postData {
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = postData
    }
    let task = newSession.dataTask(with: urlRequest) { data, response, error in
        Logger.Debug(message: "dataTask.response with data: \(data), reponse: \(response), error: \(error)")
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
            Logger.Debug(message: String(data: responseData, encoding: String.Encoding.utf8)!)
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
