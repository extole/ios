//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    public enum Me {
        static func meUrl(baseUrl: URL) -> URL {
           return URL.init(string: "/api/v4/me/", relativeTo: baseUrl)!
        }
        static func meSharesUrl(baseUrl: URL) -> URL {
           return URL.init(string: "/api/v4/me/shares/", relativeTo: baseUrl)!
        }
        static func meAssociatedFriendsUrl(baseUrl: URL) -> URL {
           return URL.init(string: "/api/v4/me/associated-friends/", relativeTo: baseUrl)!
        }
    }
}

extension ExtoleAPI.Session {
    func getShares(success: @escaping(_: [ExtoleAPI.Me.ShareResponse]) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let sharesUrl = ExtoleAPI.Me.meSharesUrl(baseUrl: self.baseUrl)
        let urlRequest = self.getRequest(url: sharesUrl)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
    
    func getAssociatedFriends(success: @escaping(_: [ExtoleAPI.Me.FriendProfileResponse]) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let friendsUrl = ExtoleAPI.Me.meAssociatedFriendsUrl(baseUrl: self.baseUrl)
        let urlRequest = self.getRequest(url: friendsUrl)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
    
    func getProfile(success: @escaping(_: ExtoleAPI.Me.MyProfileResponse) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let profileUrl = ExtoleAPI.Me.meUrl(baseUrl: self.baseUrl)
        let urlRequest = self.getRequest(url: profileUrl)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
    
    func updateProfile(
                    email: String? = nil,
                    first_name: String? = nil,
                    last_name: String? = nil,
                    profile_picture_url: String? = nil,
                    partner_user_id: String? = nil,
                    success: @escaping(_: ExtoleAPI.Me.SuccessResponse) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let profileUrl = ExtoleAPI.Me.meUrl(baseUrl: self.baseUrl)
        
        let updateRequest = ExtoleAPI.Me.PersonProfileUpdateRequest(email: email, first_name: first_name, last_name: last_name, profile_picture_url: profile_picture_url, partner_user_id: partner_user_id)
        
        let urlRequest = self.postRequest(url: profileUrl, data: updateRequest)
        
        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
}
