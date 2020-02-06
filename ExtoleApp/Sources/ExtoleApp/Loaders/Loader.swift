//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI


/// Loads content for consumer session
public protocol Loader{
    func load(session: ExtoleAPI.Session, complete: @escaping () -> Void)
}

extension ExtoleApp.SessionManager {
    public func load(loader: Loader, complete: @escaping () -> Void) {
        self.async(command: { session in
            loader.load(session: session, complete: complete)
        })
    }
}

/// Loads all child loaders, calling complete after all is loaded
public final class CompositeLoader : Loader {
    
    let loaders: [Loader]
    
    public init(loaders: [Loader]) {
        self.loaders = loaders
    }

    public func load(session:ExtoleAPI.Session, complete: @escaping () -> Void) {
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
