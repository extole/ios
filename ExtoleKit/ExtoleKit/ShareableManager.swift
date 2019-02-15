//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol ShareableManagerDelegate : class {
    func loaded(shareables: [MyShareable]?)
    func selected(shareable: MyShareable?)
    func created(code: String?)
    func error(error: GetShareablesError?)
}

public final class ShareableManager {
    weak var delegate: ShareableManagerDelegate?
    public private(set) var selectedShareable: MyShareable? = nil
    public private(set) var shareables: [MyShareable]? = nil
    public let session: ProgramSession
    let label: String

    public init(session: ProgramSession, label:String,
         delegate: ShareableManagerDelegate?) {
        self.session = session
        self.delegate = delegate
        self.label = label
    }
    
    public func load() {
        self.session.getShareables(success: onShareablesLoaded, error: { error in
            self.delegate?.error(error: error)
        })
    }

    public func new(shareable: MyShareable) {
        self.session.createShareable(shareable: shareable){ pollingId, error in
            self.session.pollShareable(pollingResponse: pollingId!, callback: { shareableResult, error in
                if let shareableResult = shareableResult {
                    self.delegate?.created(code: shareableResult.code)
                }
            })
        }
    }
    
    public func select(code: String) {
        let selected = shareables?.filter({ (shareable : MyShareable) -> Bool in
            return shareable.code == code
        }).first
        self.selectedShareable = selected
        self.delegate?.selected(shareable: selected)
    }

    private func onShareablesLoaded(shareables: [MyShareable]?) {
        self.shareables = shareables
        self.delegate?.loaded(shareables: shareables)
    }
}
