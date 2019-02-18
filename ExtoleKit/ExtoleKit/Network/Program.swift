//Copyright © 2019 Extole. All rights reserved.

import Foundation

public struct Program {
    let baseUrl: URL
    let network : Network
    public init(baseUrl: URL, network: Network = Network.init()) {
        self.baseUrl = baseUrl
        self.network = network
    }
}
