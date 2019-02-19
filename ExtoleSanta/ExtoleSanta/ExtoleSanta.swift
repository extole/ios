//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleKit

public protocol ExtoleSantaStateListener : class {
    func onStateChanged(state: ExtoleSanta.State)
}

public final class ExtoleSanta {
    
    public enum State {
        case Init
        case Identified
        case Ready
        case Loading
        
        case LoggedOut
        case ReadyToShare
        case Identify
    }
    
    var state = State.Init

    public private(set) var shareApp: ExtoleShareApp!
    
    public weak var stateListener: ExtoleSantaStateListener?
    
    convenience init(programUrl: URL) {
        self.init()
        shareApp = ExtoleShareApp(program: Program.init(baseUrl: programUrl),
                                        observer: self)
    }

    private init() {
        
    }
    
    func applicationDidBecomeActive() {
        shareApp.activate()
    }
}

extension ExtoleSanta {
    public func updateProfile(profile: MyProfile,
                              success: @escaping () -> Void,
                              error : @escaping (UpdateProfileError) -> Void) {
        shareApp.sessionManager.session?.updateProfile(profile: profile, success: success, error: error)
    }
}

extension ExtoleSanta : ExtoleAppObserver {
    public func changed(state: ExtoleApp.State) {
        switch state {
        case .Ready:
            self.state = .Ready
        default:
            self.state = .Loading
        }
    }
}
