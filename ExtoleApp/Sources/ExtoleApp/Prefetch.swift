//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

extension SessionManager {
    public func fetchMobileSharing(success: @escaping (_ mobileSharing:  MobileSharing) -> Void) {
        self.async(command: { session in
            session.renderZone(eventName: "mobile_sharing", success: success, error : { e in
            })
        })
    }
}
