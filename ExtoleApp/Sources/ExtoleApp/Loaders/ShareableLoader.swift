//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

/// Loads consumer shareable
public final class ShareableLoader : Loader{
    public private(set) var shareables: [ExtoleAPI.Me.MeShareableResponse] = []
    
    public func load(session: ExtoleAPI.Session, complete: @escaping () -> Void) {
        session.getShareables(success: { shareables in
            self.shareables = shareables
        }, error: { e in
            
        })
    }
}
