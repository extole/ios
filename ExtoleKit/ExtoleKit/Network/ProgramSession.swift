//Copyright © 2019 Extole. All rights reserved.

import Foundation

public struct ProgramSession{
    let program: Program
    let token: ConsumerToken
    var baseUrl: URL {
        get {
            return program.baseUrl
        }
    }
    
    init(program: Program, token: ConsumerToken) {
        self.program = program
        self.token = token
    }
}
