//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    @objc public final class Session: NSObject{
        let extoleAPI: ExtoleAPI
        let token: ExtoleAPI.Authorization.TokenResponse
        var baseUrl: URL {
            get {
                return extoleAPI.baseUrl
            }
        }
        var network: Network {
            get {
                return extoleAPI.network
            }
        }
        
        func getRequest(url: URL) -> URLRequest {
            let empty : String? = nil
            return network.newJsonRequest(method: "GET", url: url, headers: authorizationHeader, data: empty)
        }

        func postRequest<T : Encodable>(url: URL, data: T) -> URLRequest {
            return network.newJsonRequest(method: "POST", url: url, headers: authorizationHeader, data: data)
        }

       func putRequest<T : Encodable>(url: URL, data: T) -> URLRequest {
           return network.newJsonRequest(method: "PUT", url: url, headers: authorizationHeader, data: data)
       }

       func deleteRequest(url: URL) -> URLRequest {
           let empty : String? = nil
           return network.newJsonRequest(method: "DELETE", url: url, headers: authorizationHeader, data: empty)
       }
        
        var authorizationHeader: [String: String] {
            get {
                return [ "Authorization": token.access_token]
            }
        }
        
        @objc public var accessToken : String {
            get {
                return token.access_token
            }
        }
        
        init(extoleAPI: ExtoleAPI, token: ExtoleAPI.Authorization.TokenResponse) {
            self.extoleAPI = extoleAPI
            self.token = token
        }

        
    }
}
