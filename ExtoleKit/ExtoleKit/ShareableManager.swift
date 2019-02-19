//Copyright © 2019 Extole. All rights reserved.

import Foundation

public final class ShareableLoader {
    public private(set) var shareables: [MyShareable]? = nil
    public let session: ProgramSession

    public init(session: ProgramSession) {
        self.session = session
    }
    
    public func load(success: @escaping ([MyShareable]?) -> Void) {
        self.session.getShareables(success: { shareables in
            self.shareables = shareables
            success(shareables)
        }, error: { error in
            
        })
    }
}
