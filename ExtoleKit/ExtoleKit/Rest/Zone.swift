//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Session {
    
    public func signal(zone: String,
                        parameters: [URLQueryItem]? = nil,
                        success:@escaping () -> Void,
                        error : @escaping (ExtoleAPI.Error) -> Void) {
        var components = URLComponents(string: "\(baseUrl)/zone/\(zone)")!
        components.queryItems = parameters
        let request = self.getRequest(url: components.url!)
        self.network.processNoContentRequest(with: request, success: success, error: error)
    }

    public func fetchObject<T: Codable>(zone: String,
                            parameters: [URLQueryItem]? = nil,
                            success:@escaping (T) -> Void,
                            error : @escaping (ExtoleAPI.Error) -> Void) {
        var components = URLComponents(string: "\(baseUrl)/zone/\(zone)")!
        components.queryItems = parameters
        let request = self.getRequest(url: components.url!)
        self.network.processRequest(with: request, success: success, error: error)
    }

    public func fetchDictionary(zone: String,
                                      parameters: [URLQueryItem]?,
                                      success: @escaping (_: NSDictionary) -> Void,
                                      error : ExtoleApiErrorHandler) {
        var components = URLComponents(string: "\(baseUrl)/zone/\(zone)")!
        components.queryItems = parameters
        let request = self.getRequest(url: components.url!)
        let dictHandler : ((_: Data) -> Void) = { (data: Data) in
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
                return error.decodingError(data: data)
            }
            success(jsonObject as! NSDictionary)
        }
        self.network.processRequest(with: request, dataHandler: dictHandler, errorHandler: error)
    }
}
