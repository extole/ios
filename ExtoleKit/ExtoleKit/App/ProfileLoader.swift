//Copyright © 2019 Extole. All rights reserved.

import Foundation

/// Loads consumer profile
public final class ProfileLoader : Loader{
    public private(set) var profile: MyProfile? = nil

    public func load(session: ConsumerSession, complete: @escaping () -> Void) {
        session.getProfile(success: { profile in
            if let identified = profile {
                self.profile = identified
            }
            complete()
        }, error: { error in
            complete()
        })
    }
}
