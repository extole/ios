//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    @objc public final class Session: NSObject{
        let program: ExtoleAPI
        let token: ExtoleAPI.Token.ConsumerToken
        var baseUrl: URL {
            get {
                return program.baseUrl
            }
        }
        var network: Network {
            get {
                return program.network
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
                return [ "Authorization": token.accessToken]
            }
        }
        
        @objc public var accessToken : String {
            get {
                return token.access_token
            }
        }
        
        init(program: ExtoleAPI, token: ExtoleAPI.Token.ConsumerToken) {
            self.program = program
            self.token = token
        }
        
        static func v4TokenUrl(baseUrl: URL) -> URL {
           return URL.init(string: "/api/v4/token/", relativeTo: baseUrl)!
        }
        
        static func v5TokenUrl(baseUrl: URL) -> URL {
           return URL.init(string: "/api/v4/token/", relativeTo: baseUrl)!
        }
        
        public func verify(success : @escaping (_: ExtoleAPI.Token.ConsumerToken) -> Void,
                           error: @escaping (_: ExtoleAPI.Error) -> Void) {
            let url = URL.init(string: token.access_token, relativeTo: ExtoleAPI.Session.v4TokenUrl(baseUrl: baseUrl))!
            let request = self.getRequest(url: url)
            self.network.processRequest(with: request, success: success, error: error)
        }

        public func invalidate(success: @escaping ()->Void,
                               error:  @escaping (_: ExtoleAPI.Error) -> Void) {
            let url = URL.init(string: token.access_token, relativeTo: ExtoleAPI.Session.v4TokenUrl(baseUrl: baseUrl))!
            let request = self.deleteRequest(url: url)
            extoleDebug(format: "deleteToken : %{public}@", arg: url.absoluteString)
            self.network.processNoContentRequest(with: request, success: success, error: error)
        }
    }
}
