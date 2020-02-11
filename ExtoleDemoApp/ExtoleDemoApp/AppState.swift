//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleApp

class AppState : ObservableObject {
    public let settings = UserDefaults(suiteName: "ExtoleDemoApp")!
    
    var program: ExtoleApp.Program!
    @Published var shareExperience: ExtoleApp.AdvocateMobileExperience? = nil
    
    init () {
        self.reset()
    }

    public func reset() {
        let savedAccessToken: String? = settings.string(forKey: "access_token");
        self.program = Extole(programDomain: "ios-santa.extole.io")
                   .session(accessToken: savedAccessToken)
                   .program()
    }
    public func refresh() {
        self.program.ready { mobileExperience in
            self.program.sessionManager.async { session in
                self.settings.set(session.accessToken,
                                  forKey: "access_token");
            }
            sleep(10)
            DispatchQueue.main.async {
                self.shareExperience = mobileExperience
            }
        }
    }
}
