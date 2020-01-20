//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    public class Error: Codable {
        let code: String
        let httpCode: Int?
        let message: String?
        init(code: String, message: String? = nil, httpCode: Int? = nil) {
            self.code = code;
            self.httpCode = httpCode;
            self.message = message
        }
    }
    
    public struct ServerError: Codable {
        let code: String
        let message: String
        let unique_id: String
        let http_status_code: Int
    }
}
