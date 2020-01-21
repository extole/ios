//Copyright © 2019 Extole. All rights reserved.

import Foundation

public final class ExtoleAPI {
    let baseUrl: URL
    let network : Network
    let appName : String?
    let appVersion : String?
    public init(programDomain: String,
                appName: String? = nil,
                appVersion: String? = nil,
                network : Network = Network.init()) {
        self.baseUrl = URL.init(string: "https://" + programDomain)!
        self.appName = appName
        self.appVersion = appVersion
        self.network = network
    }
}
