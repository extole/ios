//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public final class EmailShare : NSObject, Codable {
    public init(advocate_code: String? = nil, recipient_email: String,
         message: String,
         subject: String,
         data: [String:String]? = nil) {
        self.advocate_code = advocate_code
        self.subject = subject
        self.message = message
        self.recipient_email = recipient_email
        self.data = data
    }
    var advocate_code: String?
    var message: String
    var subject: String
    var recipient_email: String
    var data: [String:String]?
}

@objc public final class EmailSharePollingResult : NSObject, Codable {
    let polling_id : String
    let status : String
    let share_id : String?
}

extension ExtoleAPI.Session {
    
    
    
}
