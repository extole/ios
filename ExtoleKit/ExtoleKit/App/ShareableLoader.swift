//Copyright © 2019 Extole. All rights reserved.

import Foundation

/// Handles shareable loader events
public protocol ShareableLoaderDelegate : class {
    func success(shareables: [MyShareable], complete: @escaping () -> Void)
}

/// Loads shareables for consumer session
public final class ShareableLoader : Loader {
    public private(set) var shareables: [MyShareable]? = nil
    private weak var delegate: ShareableLoaderDelegate?

    public init(delegate: ShareableLoaderDelegate) {
        self.delegate = delegate
    }
    
    public func load(session: ExtoleAPI.Session, complete: @escaping () -> Void) {
        session.getShareables(success: { shareables in
            self.shareables = shareables
            self.delegate?.success(shareables: shareables, complete: complete)
        }, error: { error in
            complete()
        })
    }
}
