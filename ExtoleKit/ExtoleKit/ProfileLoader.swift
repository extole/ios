//Copyright © 2019 Extole. All rights reserved.

import Foundation

public final class ProfileLoader : Loader{
    public private(set) var profile: MyProfile? = nil
    let success: (MyProfile) -> Void
    
    public init(success: @escaping (MyProfile) -> Void) {
        self.success = success
    }
    
    public func load(session: ProgramSession, complete: @escaping () -> Void) {
        session.getProfile(success: { profile in
            if let identified = profile {
                self.profile = identified
                self.success(identified)
            }
            complete()
        }, error: { error in
            complete()
        })
    }
}
