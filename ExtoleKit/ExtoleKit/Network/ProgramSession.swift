//
//  ProgramSession.swift
//  ExtoleKit
//
//  Created by rtibin on 2/13/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public struct ProgramSession{
    let program: Program
    public let token: ConsumerToken
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
