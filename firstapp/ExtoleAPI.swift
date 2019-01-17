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
    
    public struct ConsumerToken : Codable {
        let access_token: String
        let expires_in: Int
        let scopes: [String]
        let capabilities: [String]
    }
    
    public class APIResponse {
        var consumerToken: ConsumerToken?
        let waitGroup : DispatchGroup
        init() {
            waitGroup = DispatchGroup.init()
            waitGroup.enter()
        }
        func setConsumerToken(consumerToken: ConsumerToken?) -> Void{
            self.consumerToken = consumerToken
            waitGroup.leave()
        }
        
        public func await(timeout: DispatchTime) -> ConsumerToken? {
            waitGroup.wait(timeout: timeout)
            return self.consumerToken
        }
    }

    public func getToken() -> APIResponse {
        let apiResponse = APIResponse.init()
        
        let url = URL(string: "\(baseUrl)/api/v4/token")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                Logger.Error(message: "Error fetching \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    Logger.Error(message: "Server error")
                    return
            }
            if let responseData = data {
                let decoder = JSONDecoder.init()
                let consumerToken = try? decoder.decode(ConsumerToken.self, from: responseData)
                Logger.Info(message: "Received response :\(consumerToken)")
                apiResponse.setConsumerToken(consumerToken: consumerToken)
            } else {
                Logger.Info(message: "Received no data")
            }
            
        }
        task.resume()
        return apiResponse
    }
}
