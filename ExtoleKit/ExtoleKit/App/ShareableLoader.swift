//Copyright © 2019 Extole. All rights reserved.

import Foundation

/// Handles shareable loader events
public protocol ShareableLoaderDelegate : class {
    func success(shareables: [MyShareable]?)
}

/// Loads shareables for consumer session
public final class ShareableLoader : Loader {
    public private(set) var shareables: [MyShareable]? = nil
    private weak var delegate: ShareableLoaderDelegate?

    public init(delegate: ShareableLoaderDelegate) {
        self.delegate = delegate
    }
    
    public func load(session: ConsumerSession, complete: @escaping () -> Void) {
        session.getShareables(success: { shareables in
            self.shareables = shareables
            self.delegate?.success(shareables: shareables)
            complete()
        }, error: { error in
            complete()
        })
    }
}
