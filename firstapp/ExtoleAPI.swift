//
//  ExtoleAPI.swift
//  firstapp
//
//  Created by rtibin on 1/17/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public class ExtoleAPI {
    
    var baseUrl : String = "https://roman-tibin-test.extole.com";
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    public struct ConsumerToken : Codable {
        var access_token: String
        var expires_in: Int
        var scopes: [String]
        var capabilities: [String]
    }
    
    public func getToken(reponseHandler : @escaping (ConsumerToken?) -> Void) -> Void {
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
                reponseHandler(consumerToken)
            } else {
                Logger.Info(message: "Received no data")
            }
            
        }
        task.resume()
    }
}
