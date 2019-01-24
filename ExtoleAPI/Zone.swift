//
//  Zone.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

extension Program {
    
    public func fetchZone(accessToken: String?, zone: String) -> APIResponse<Data> {
        let url = URL(string: "\(baseUrl)/zone/\(zone)")!
        return contentTask(url: url, accessToken: accessToken)
    }
    
    func contentTask(url: URL, accessToken: String?) -> APIResponse<Data> {
        let apiResponse = APIResponse<Data>.init()
        Logger.Info(message: "dataTask with \(url)")
        let newSession = URLSession.init(configuration: URLSessionConfiguration.ephemeral)
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("curl/7.54.0", forHTTPHeaderField: "User-Agent")
        urlRequest.addValue("*/*", forHTTPHeaderField: "Accept")
        if let existingToken = accessToken {
            Logger.Info(message: "using accessToken \(existingToken)")
            urlRequest.addValue(existingToken, forHTTPHeaderField: "Authorization")
        }
        let task = newSession.dataTask(with: urlRequest) { data, response, error in
            Logger.Debug(message: "dataTask.response with data: \(data), reponse: \(response), error: \(error)")
            if let error = error {
                apiResponse.setError(error: error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    if let responseData = data {
                        let decodedError: ErrorData? = tryDecode(data: responseData)
                        if let decodedError = decodedError {
                            apiResponse.setError(error: ExtoleServerError.serverError(errorData: decodedError))
                        } else {
                            apiResponse.setError(error: ExtoleServerError.encodingError)
                        }
                    } else {
                        apiResponse.setError(error: ExtoleServerError.noContent)
                    }
                    return
            }
            if let responseData = data {
                apiResponse.setData(data: responseData)
            } else {
                apiResponse.setError(error: ExtoleServerError.noContent)
            }
            
        }
        task.resume()
        return apiResponse
    }
}
