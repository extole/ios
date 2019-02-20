//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol Loader{
    func load(session: ProgramSession, complete: @escaping () -> Void)
}

public class CompositeLoader : Loader {
    
    let loaders: [Loader]
    
    public init(loaders: [Loader]) {
        self.loaders = loaders
    }

    public func load(session:ProgramSession, complete: @escaping () -> Void) {
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
