//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ConsumerSession {
    
    public func fetchObject<T: Codable>(zone: String,
                            success:@escaping (T) -> Void,
                            error : @escaping (ExtoleError) -> Void) {
        let url = URL(string: "\(baseUrl)/zone/\(zone)")!
        let request = self.network.getRequest(accessToken: token,
                                 url: url)
        self.network.processRequest(with: request, success: success, error: error)
    }

    @objc public func fetchDictionary(zone: String,
                                        success: @escaping (_: NSDictionary) -> Void,
                                        error : ExtoleApiErrorHandler) {
        let url = URL(string: "\(baseUrl)/zone/\(zone)")!
        let request = self.network.getRequest(accessToken: token,
                                              url: url)
        let dictHandler : ((_: Data) -> Void) = { (data: Data) in
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
                return error.decodingError(data: data)
            }
            success(jsonObject as! NSDictionary)
        }
        self.network.processRequest(with: request, dataHandler: dictHandler, errorHandler: error)
    }
}
