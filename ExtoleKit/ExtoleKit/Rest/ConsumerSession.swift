//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public final class ConsumerSession: NSObject{
    let program: ProgramURL
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
    
    @objc public var accessToken : String {
        get {
            return token.access_token
        }
    }
    
    init(program: ProgramURL, token: ConsumerToken) {
        self.program = program
        self.token = token
    }
}
