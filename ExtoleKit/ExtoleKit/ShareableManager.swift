//Copyright © 2019 Extole. All rights reserved.

import Foundation

public final class ShareableLoader : Loader {
    public private(set) var shareables: [MyShareable]? = nil
    public let session: ProgramSession
    private let success: ([MyShareable]?) -> Void

    public init(session: ProgramSession, success: @escaping ([MyShareable]?) -> Void) {
        self.session = session
        self.success = success
    }
    
    public func load(complete: @escaping () -> Void) {
        self.session.getShareables(success: { shareables in
            self.shareables = shareables
            self.success(shareables)
            complete()
        }, error: { error in
            complete()
        })
    }
}
