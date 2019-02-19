//Copyright © 2019 Extole. All rights reserved.

import Foundation

public final class ProfileLoader {
    public let session: ProgramSession
    public private(set) var profile: MyProfile? = nil
    
    public init(session: ProgramSession) {
        self.session = session
    }
    
    public func load(success: @escaping (MyProfile) -> Void) {
        self.session.getProfile(success: { profile in
            if let identified = profile {
                self.profile = identified
                success(identified)
            }
        }, error: { error in
            
        })
    }
}
