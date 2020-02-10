//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleApp

class AppState : ObservableObject {
    @Published var shareExperience: ExtoleApp.AdvocateMobileExperience? = nil
    var program: ExtoleApp.Program =  Extole(programDomain: "ios-santa.extole.io")
        .session().program()
    
    public func refresh() {
        self.program.ready { mobileExperience in
            DispatchQueue.main.async {
                self.shareExperience = mobileExperience
            }
        }
    }
}
