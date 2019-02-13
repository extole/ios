//
//  ShareableManager.swift
//  ExtoleKit
//
//  Created by rtibin on 2/13/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public enum ShareableState : String {
    case Init = "Init"
    case Loaded = "Loaded"
    case Selected = "Selected"
}

public protocol ShareableStateListener : AnyObject {
    func onStateChanged(state: ShareableState)
}

public final class ShareableManager {
    weak var listener: ShareableStateListener?
    var shareables: [MyShareable]? = nil
    public private(set) var selectedShareable: MyShareable? = nil
    let session: ProgramSession
    let label: String
    var state = ShareableState.Init {
        didSet {
            extoleInfo(format: "state changed to %{public}@", arg: state.rawValue)
            listener?.onStateChanged(state: state)
        }
    }
    
    init(session: ProgramSession, label:String, listener: ShareableStateListener?) {
        self.session = session
        self.listener = listener
        self.label = label
    }
    
    public func load() {
        state = .Init
        self.session.getShareables(callback: onShareablesLoaded)
    }

    private func onShareablesLoaded(shareables: [MyShareable]?, error: GetShareablesError?) {
        if let shareable = shareables?.filter({ (shareable : MyShareable) -> Bool in
            return shareable.label == self.label
        }).first {
            self.selectedShareable = shareable
            self.state = .Selected
        } else {
            let newShareable = MyShareable.init(label: self.label,
                                                key: self.label)
            self.session.createShareable(shareable: newShareable){ pollingId, error in
                self.session.pollShareable(pollingResponse: pollingId!, callback: { shareableResult, error in
                    self.session.getShareables(callback: self.onShareablesLoaded)
                })
            }
        }
    }
}
