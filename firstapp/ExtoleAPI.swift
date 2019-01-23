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
    
    public struct PollingIdResponse : Codable {
        let polling_id : String
    }
    
    public struct PollingResult : Codable {
        let polling_id : String
        let status : String
    }
    
    public struct ErrorData: Codable {
        let code: String
    }
    
    public struct MyShareable : Codable {
        //let code: String
        let label: String
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
        return dataTask(url: url, accessToken: accessToken.access_token, postData: nil)
    }
    
    public func createShareable(accessToken: ConsumerToken, shareable: MyShareable)
        -> APIResponse<PollingResult> {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables")!
        let shareableData = try? JSONEncoder().encode(shareable)
        let pollingResponse : PollingIdResponse?
        pollingResponse = dataTask(url: url, accessToken: accessToken.access_token, postData: shareableData).await(timeout: DispatchTime.now() + .seconds(100))
        return pollShareable(accessToken: accessToken, pollingResponse: pollingResponse!)
    }
    
    private func pollShareable(accessToken: ConsumerToken, pollingResponse: PollingIdResponse)
        -> APIResponse<PollingResult> {
         let url = URL(string: "\(baseUrl)/api/v5/me/shareables/status/\(pollingResponse.polling_id)")!
         return dataTask(url: url, accessToken: accessToken.access_token, postData: nil)
    }
    
    public func getToken() -> APIResponse<ConsumerToken> {
        let url = URL(string: "\(baseUrl)/api/v4/token")!
        return dataTask(url: url, accessToken: nil, postData: nil)
    }
    
    public func fetchZone(accessToken: String?, zone: String) -> APIResponse<Data> {
        let url = URL(string: "\(baseUrl)/zone/\(zone)")!
        return contentTask(url: url, accessToken: accessToken)
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
                Logger.Debug(message: String(data: responseData, encoding: String.Encoding.utf8)!)
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
                apiResponse.setData(data: responseData)
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
