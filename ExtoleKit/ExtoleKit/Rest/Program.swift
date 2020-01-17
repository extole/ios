//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public final class Program : NSObject {
    let baseUrl: URL
    let network : Network
    @objc public init(programURL: URL, network: Network = Network.init()) {
        self.baseUrl = programURL
        self.network = network
    }
}
