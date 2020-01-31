//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

extension SessionManager {
    public func prefetch(success: @escaping (_ mobileSharing:  MobileSharing) -> Void) {
        let loader = MobileSharingLoader()
        self.async(command: { session in
            loader.load(session: session, complete: {
                if let sharingResponse = loader.mobileSharing {
                  success(sharingResponse)
                }
            })
        })
    }
}
