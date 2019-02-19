//Copyright © 2019 Extole. All rights reserved.

import Foundation

public final class ProfileLoader : Loader{
    public let session: ProgramSession
    public private(set) var profile: MyProfile? = nil
    let success: (MyProfile) -> Void
    
    public init(session: ProgramSession, success: @escaping (MyProfile) -> Void) {
        self.session = session
        self.success = success
    }
    
    public func load(complete: @escaping () -> Void) {
        self.session.getProfile(success: { profile in
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
