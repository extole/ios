//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public final class ExtoleError: NSObject, Codable {
    @objc public let code: String
    public init(code: String) {
        self.code = code
    }
}
