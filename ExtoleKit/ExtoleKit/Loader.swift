//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol Loader{
    func load(complete: @escaping () -> Void)
}

public class CompositeLoader : Loader {
    
    let loaders: [Loader]
    
    public init(loaders: [Loader]) {
        self.loaders = loaders
    }

    public func load(complete: @escaping () -> Void) {
        var inProgress = loaders
        func onComplete() {
            inProgress.removeFirst()
            if let next = inProgress.first {
                next.load(complete: onComplete)
            } else {
                complete()
            }
        }
        if let first = inProgress.first {
            first.load(complete: onComplete)
        } else {
            complete()
        }
    }
}
