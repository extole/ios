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
    public var advocate_code: String?
    public var message: String
    public var subject: String
    public var recipient_email: String
    public var data: [String:String]?
}

@objc public final class EmailSharePollingResult : NSObject, Codable {
    let polling_id : String
    let status : String
    let share_id : String?
}

extension ExtoleAPI.Session {
    
    
    
}
