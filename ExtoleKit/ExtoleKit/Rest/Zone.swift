//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ConsumerSession {
    
    public func fetchObject<T: Codable>(zone: String,
                            success:@escaping (T?) -> Void,
                            error : @escaping (ExtoleError) -> Void) {
        let url = URL(string: "\(baseUrl)/zone/\(zone)")!
        let request = self.network.getRequest(accessToken: token,
                                 url: url)
        self.network.processRequest(with: request, success: success, error: error)
    }
}
