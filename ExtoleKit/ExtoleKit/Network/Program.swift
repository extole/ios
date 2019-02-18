//Copyright © 2019 Extole. All rights reserved.

import Foundation

public struct Program {
    let baseUrl: URL
    let network = Network.init()
    public init(baseUrl: URL) {
        self.baseUrl = baseUrl
    }
}
