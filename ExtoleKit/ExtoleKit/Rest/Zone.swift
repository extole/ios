//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ConsumerSession {
    
    public enum GetObjectError : ExtoleError {
        public static func toInvalidProtocol(error: ExtoleApiError) -> ExtoleError {
            return GetObjectError.invalidProtocol(error: error)
        }
        
        public static func fromCode(code: String) -> ExtoleError? {
            switch(code) {
            case "invalid_access_token": return GetTokenError.invalidAccessToken
            default: return nil
            }
        }
        
        case invalidProtocol(error: ExtoleApiError)
        case invalidAccessToken
    }
    
    public func fetchObject<T: Codable>(zone: String,
                            success:@escaping (T?) -> Void,
                            error : @escaping (GetObjectError?) -> Void) {
        let url = URL(string: "\(baseUrl)/zone/\(zone)")!
        let request = self.network.getRequest(accessToken: token,
                                 url: url)
        self.network.processRequest(with: request, success: success, error: error)
    }
}
