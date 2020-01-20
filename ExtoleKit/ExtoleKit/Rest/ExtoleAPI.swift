//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public final class ExtoleAPI : NSObject {
    let baseUrl: URL
    let network : Network
    @objc public init(programDomain: String, network: Network = Network.init()) {
        self.baseUrl = URL.init(string: "https://" + programDomain)!
        self.network = network
    }
}
