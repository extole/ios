//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

/// Loads consumer profile
public final class ProfileLoader : Loader{
    public private(set) var profile: ExtoleAPI.Me.MyProfileResponse? = nil
    
    public init() {
        
    }
    public func load(session: ExtoleAPI.Session, complete: @escaping () -> Void) {
        session.getProfile(success: { profile in
            self.profile = profile
            complete()
        }, error: { error in
            complete()
        })
    }
}
