//Copyright © 2019 Extole. All rights reserved.

import Foundation

class SimpleShareExperince: HasShareApp, ShareExperience {
    
    let shareApp: ExtoleShareApp
    let appDelegate = SimpleShareAppDelegate()
    
    init(programUrl: URL, programLabel: String) {
        
        self.shareApp = ExtoleShareApp.init(programUrl: programUrl, programLabel: programLabel, delegate: appDelegate)
    }
    
    var isValid: Bool? {
        get {
            return appDelegate.isValid
        }
    }
}

class SimpleShareAppDelegate : ExtoleShareAppDelegate {

    var isValid : Bool?;
    
    func extoleShareAppInvalid() {
        isValid = false;
    }
    
    func extoleShareAppReady() {
         isValid = true;
    }
}
