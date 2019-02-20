//Copyright © 2019 Extole. All rights reserved.

import Foundation

public struct MyProfile : Codable {
    public init(email: String? = nil, partner_user_id: String? = nil,
         first_name:String? = nil, last_name:String? = nil) {
        self.email = email
        self.partner_user_id = partner_user_id
        self.first_name = first_name
        self.last_name = last_name
    }
    public let email: String?
    public let first_name: String?
    public let last_name: String?
    public let partner_user_id: String?
}

public struct SuccessResponse : Codable {
    let status: String
}

public enum GetProfileError : ExtoleError {
    public static func fromCode(code: String) -> ExtoleError? {
        switch(code) {
        case "invalid_access_token": return GetProfileError.invalidAccessToken
        default: return nil
        }
    }
    
    public static func toInvalidProtocol(error: ExtoleApiError) -> ExtoleError {
        return GetProfileError.invalidProtocol(error: error)
    }
    
    case invalidProtocol(error: ExtoleApiError)
    case invalidAccessToken
}


public enum UpdateProfileError : ExtoleError {
    public static func fromCode(code: String) -> ExtoleError? {
        switch(code) {
        case "invalid_access_token": return UpdateProfileError.invalidAccessToken
        case "invalid_person_email": return UpdateProfileError.invalidPersonEmail
        default: return nil
        }
    }
    
    public static func toInvalidProtocol(error: ExtoleApiError) -> ExtoleError {
        return UpdateProfileError.invalidProtocol(error: error)
    }
    case invalidProtocol(error: ExtoleApiError)
    case invalidPersonEmail
    case invalidAccessToken
}

extension ProgramSession {
    
    public func updateProfile(profile: MyProfile,
                              success: @escaping () -> Void,
                              error : @escaping (UpdateProfileError) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v4/me")!
        let request = self.network.postRequest(accessToken: token,
                                 url: url,
                                 data: profile)
        self.network.processNoContentRequest(with: request, success: success, error: error)
    }

    public func getProfile(success: @escaping (MyProfile?) -> Void,
                           error: @escaping (GetProfileError) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v4/me")!
        let request = self.network.getRequest(accessToken: token,
                                              url: url)
        self.network.processRequest(with: request, success: success, error: error)
        
    }
}
