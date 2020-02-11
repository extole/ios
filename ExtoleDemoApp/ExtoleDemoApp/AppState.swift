//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleApp
import ExtoleAPI

class AppState : ObservableObject, ExtoleApp.SessionManager.Delegate {
    func onSessionInvalid() {
        settings.removeObject(forKey: "access_token")
        self.reset()
    }
    
    func onSessionDeleted() {
        settings.removeObject(forKey: "access_token")
        self.reset()
    }
    
    func onNewSession(session: ExtoleAPI.Session) {
        self.settings.set(session.accessToken, forKey: "access_token");
        self.refresh()
    }

    func onSessionServerError(error: ExtoleAPI.Error) {
        
    }
    
    public let settings = UserDefaults(suiteName: "ExtoleDemoApp")!
    
    var program: ExtoleApp.Program!
    @Published var shareExperience: ExtoleApp.AdvocateMobileExperience? = nil
    
    init () {
        self.reset()
    }

    public var isLogged : Bool {
        get {
            if let email = shareExperience?.me.email {
                return !email.isEmpty
            }
            return false
        }
    }
    public func logout() {
        program.sessionManager.logout();
    }
    
    public func reset() {
        let savedAccessToken: String? = settings.string(forKey: "access_token");
        self.program = Extole(programDomain: "ios-santa.extole.io")
                   .session(accessToken: savedAccessToken, delegate: self)
                   .program()
    }
    
    public func refresh() {
        self.program.ready { mobileExperience in
            DispatchQueue.main.async {
                self.shareExperience = mobileExperience
            }
        }
    }
    
    public func shared(channel: String) {
        program.share(data: ["channel" : channel], success: {_ in 
            
        }, error: { e in
            
        })
    }
}
