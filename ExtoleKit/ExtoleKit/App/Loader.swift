//Copyright © 2019 Extole. All rights reserved.

import Foundation

/// Loads content for consumer session
@objc public protocol Loader{
    func load(session: ExtoleSession, complete: @escaping () -> Void)
}

/// Loads all child loaders, calling complete after all is loaded
public final class CompositeLoader : Loader {
    
    let loaders: [Loader]
    
    public init(loaders: [Loader]) {
        self.loaders = loaders
    }

    public func load(session:ExtoleSession, complete: @escaping () -> Void) {
        var inProgress = loaders
        func onComplete() {
            inProgress.removeFirst()
            if let next = inProgress.first {
                next.load(session: session, complete: onComplete)
            } else {
                complete()
            }
        }
        if let first = inProgress.first {
            first.load(session: session, complete: onComplete)
        } else {
            complete()
        }
    }
}
