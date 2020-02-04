//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    public class Error: Codable {
        let code: String
        let message: String?
        let httpCode: Int?
        let parameters: [String:String]?
        public init(code: String, message: String, httpCode: Int? = nil,
                    parameters: [String:String]? = nil) {
            self.code = code;
            self.httpCode = httpCode;
            self.message = message
            self.parameters = parameters
        }
    }
    
    public struct ServerError: Codable {
        let code: String
        let message: String
        let unique_id: String
        let http_status_code: Int
        let parameters: [String: String]?
    }
}
