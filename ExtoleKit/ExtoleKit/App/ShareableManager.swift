//Copyright © 2019 Extole. All rights reserved.

import Foundation

public final class ShareableLoader : Loader {
    public private(set) var shareables: [MyShareable]? = nil
    private let success: ([MyShareable]?) -> Void

    public init(success: @escaping ([MyShareable]?) -> Void) {
        self.success = success
    }
    
    public func load(session: ProgramSession, complete: @escaping () -> Void) {
        session.getShareables(success: { shareables in
            self.shareables = shareables
            self.success(shareables)
            complete()
        }, error: { error in
            complete()
        })
    }
}
