//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

/// Loads consumer profile
public final class MobileSharingLoader : Loader {
    public private(set) var mobileSharing: MobileSharing? = nil
    
    public func load(session: ExtoleAPI.Session, complete: @escaping () -> Void) {
        session.renderZone(eventName: "mobile_sharing",
                           success: { (mobileSharing: MobileSharing) in
            self.mobileSharing = mobileSharing;
            complete()
        }, error: { error in
            complete()
        })
    }
}
