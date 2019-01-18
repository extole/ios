//
//  ExtoleAPI.swift
//  firstapp
//
//  Created by rtibin on 1/17/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public class ExtoleAPI {
    
    let baseUrl : String;
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    enum ExtoleServerError : Error {
        case serverError(errorData: ErrorData)
        case encodingError
        case noContent
    }
    
    public struct ConsumerToken : Codable {
        let access_token: String
        let expires_in: Int
        let scopes: [String]
        let capabilities: [String]
    }
    
    public struct ErrorData: Codable {
        let code: String
    }
    
    public struct MyShareable : Codable {
        let code: String
    }
    
    public class APIResponse<T: Codable> {
        var data: T?
        var error: Error?
        let waitGroup : DispatchGroup
        init() {
            waitGroup = DispatchGroup.init()
            waitGroup.enter()
        }
        
        func setData(data: T) -> Void{
            self.data = data
            waitGroup.leave()
        }
        
        func setError(error: Error) -> Void{
            Logger.Error(message: "API error \(error)")
            self.error = error
            waitGroup.leave()
        }
        
        public func await(timeout: DispatchTime) -> T? {
            waitGroup.wait(timeout: timeout)
            return self.data
        }
    }

    public func getShareables(accessToken: ConsumerToken) -> APIResponse<[MyShareable]> {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables")!
        return dataTask(url: url, accessToken: accessToken.access_token)
    }
    
    public func getToken() -> APIResponse<ConsumerToken> {
        let url = URL(string: "\(baseUrl)/api/v4/token")!
        return dataTask(url: url, accessToken: nil)
    }
    
    func dataTask<T: Codable> (url: URL, accessToken: String?) -> APIResponse<T> {
        let apiResponse = APIResponse<T>.init()
        Logger.Info(message: "dataTask with \(url)")
        let newSession = URLSession.init(configuration: URLSessionConfiguration.ephemeral)
        var urlRequest = URLRequest(url: url)
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
                        let decodedError: ErrorData? = ExtoleAPI.tryDecode(data: responseData)
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
                let decodedData: T? = ExtoleAPI.tryDecode(data: responseData)
                if let decodedData = decodedData {
                    apiResponse.setData(data: decodedData)
                } else {
                     apiResponse.setError(error: ExtoleServerError.encodingError)
                }
            } else {
                apiResponse.setError(error: ExtoleServerError.noContent)
            }
            
        }
        task.resume()
        return apiResponse
    }
    
    static func tryDecode<T: Codable>(data: Data) -> T? {
        let decoder = JSONDecoder.init()
        return try? decoder.decode(T.self, from: data)
    }
}
