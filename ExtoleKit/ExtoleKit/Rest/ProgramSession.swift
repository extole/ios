//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public final class ProgramSession: NSObject{
    let program: ExtoleAPI
    let token: ConsumerToken
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
    
    init(program: ExtoleAPI, token: ConsumerToken) {
        self.program = program
        self.token = token
    }
}
