//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    public enum Me {
    }
}

func meUrl(baseUrl: URL) -> URL {
   return URL.init(string: "/api/v4/me/", relativeTo: baseUrl)!
}

func meSharesUrl(baseUrl: URL) -> URL {
   return URL.init(string: "/api/v4/me/shares/", relativeTo: baseUrl)!
}

func meShareablesUrl(baseUrl: URL) -> URL {
   return URL.init(string: "/api/v6/me/shareables/", relativeTo: baseUrl)!
}

func meRewardsUrl(baseUrl: URL) -> URL {
   return URL.init(string: "/api/v4/me/rewards/", relativeTo: baseUrl)!
}

func meAssociatedFriendsUrl(baseUrl: URL) -> URL {
   return URL.init(string: "/api/v4/me/associated-friends/", relativeTo: baseUrl)!
}

extension ExtoleAPI.Session {
    public func getShares(success: @escaping(_: [ExtoleAPI.Me.ShareResponse]) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let sharesUrl = meSharesUrl(baseUrl: self.baseUrl)
        let urlRequest = self.getRequest(url: sharesUrl)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
    
    public func getShareables(success: @escaping(_: [ExtoleAPI.Me.MeShareableResponse]) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let sharesUrl = meShareablesUrl(baseUrl: self.baseUrl)
        let urlRequest = self.getRequest(url: sharesUrl)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
    
    public func getShareable(code: String, success: @escaping(_: ExtoleAPI.Me.MeShareableResponse) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let shareableByCodeUrl = URL.init(string: code,
                                          relativeTo: meShareablesUrl(baseUrl: self.baseUrl))!
        
        let urlRequest = self.getRequest(url: shareableByCodeUrl)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
    
    public func createShareable(preferred_code_prefixes: [String]? = nil,
                                key: String? = nil,
                                label: String? = nil,
                                content: ExtoleAPI.Me.ShareableContent? = nil,
                                data: [String : String] = [:],
                                success: @escaping(_: ExtoleAPI.Me.MeShareableResponse) -> Void,
                                error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let sharesUrl = meShareablesUrl(baseUrl: self.baseUrl)
        let createShareableRequest = ExtoleAPI.Me.CreateMeShareableRequest(preferred_code_prefixes: preferred_code_prefixes
            , key: key, label: label, content: content, data: data)
        let urlRequest = self.postRequest(url: sharesUrl, data: createShareableRequest)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
    
    public func getAssociatedFriends(success: @escaping(_: [ExtoleAPI.Me.FriendProfileResponse]) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let friendsUrl = meAssociatedFriendsUrl(baseUrl: self.baseUrl)
        let urlRequest = self.getRequest(url: friendsUrl)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
    
    public func getProfile(success: @escaping(_: ExtoleAPI.Me.MyProfileResponse) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let profileUrl = meUrl(baseUrl: self.baseUrl)
        let urlRequest = self.getRequest(url: profileUrl)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
    
    public func getRewards(success: @escaping(_: [ExtoleAPI.Me.RewardResponse]) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let rewardsUrl = meRewardsUrl(baseUrl: self.baseUrl)
        let urlRequest = self.getRequest(url: rewardsUrl)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
    
    public func updateProfile(
                    email: String? = nil,
                    first_name: String? = nil,
                    last_name: String? = nil,
                    profile_picture_url: String? = nil,
                    partner_user_id: String? = nil,
                    success: @escaping() -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let profileUrl = meUrl(baseUrl: self.baseUrl)
        
        let updateRequest = ExtoleAPI.Me.PersonProfileUpdateRequest(email: email, first_name: first_name, last_name: last_name, profile_picture_url: profile_picture_url, partner_user_id: partner_user_id)
        
        let urlRequest = self.postRequest(url: profileUrl, data: updateRequest)
        
        self.network.processRequest(with: urlRequest, success: { (status : ExtoleAPI.Me.SuccessResponse ) in
            success()
        }, error: error)
    }
}
