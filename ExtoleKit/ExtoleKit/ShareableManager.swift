//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol ShareableManagerDelegate : class {
    func shareableSelected(shareable: MyShareable)
}

public final class ShareableManager {
    weak var delegate: ShareableManagerDelegate?
    public private(set) var selectedShareable: MyShareable? = nil
    public let session: ProgramSession
    let label: String
    var shareableKey: String?

    public init(session: ProgramSession, label:String, shareableKey: String?,
         delegate: ShareableManagerDelegate?) {
        self.session = session
        self.delegate = delegate
        self.label = label
        self.shareableKey = shareableKey
    }
    
    public func load() {
        self.session.getShareables(callback: onShareablesLoaded)
    }

    private func onShareablesLoaded(shareables: [MyShareable]?, error: GetShareablesError?) {
        if let shareable = shareables?.filter({ (shareable : MyShareable) -> Bool in
            return shareable.key == self.shareableKey
        }).first {
            self.selectedShareable = shareable
            self.delegate?.shareableSelected(shareable: shareable)
        } else {
            self.shareableKey = NSUUID().uuidString
            let newShareable = MyShareable.init(label: self.label,
                                                key: self.shareableKey)
            self.session.createShareable(shareable: newShareable){ pollingId, error in
                self.session.pollShareable(pollingResponse: pollingId!, callback: { shareableResult, error in
                    self.session.getShareables(callback: self.onShareablesLoaded)
                })
            }
        }
    }
}
