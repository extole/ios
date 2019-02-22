//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public final class ConsumerSession: NSObject{
    let program: ProgramURL
    let token: ConsumerToken
    let network = Network.init()
    var baseUrl: URL {
        get {
            return program.baseUrl
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
