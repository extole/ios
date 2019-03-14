//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleKit

protocol ExtoleSantaDelegate: class {
    func santaIsBusy()
    func santaIsReady()
}

struct ShareSettings : Codable {
    let shareMessage: String?
    let item1: String?
    let item2: String?
    let item3: String?
    let item4: String?
}

class ExtoleSanta : HasShareApp, DefaultShareExperince {

    /// Loads consumer profile
    public private(set) var profileLoader = ProfileLoader()
    /// Loads share settings
    public private(set) var settingsLoader = ZoneLoader<ShareSettings>(zoneName: "settings")
    
    init(delegate: ExtoleSantaDelegate) {
        self.delegate = delegate
    }
    weak var delegate : ExtoleSantaDelegate?
    
    lazy var shareApp = ExtoleShareApp(programUrl: URL.init(string: "https://ios-santa.extole.io")!,
                                       programLabel: "refer-a-friend",
                                       delegate: self,
                                       extraLoaders: [profileLoader, settingsLoader])
    var profile: MyProfile? {
        get {
            return profileLoader.profile
        }
    }
    
    var shareSettings : ShareSettings? {
        get {
            return settingsLoader.zoneData
        }
    }
    
}

extension ExtoleSanta : ExtoleShareAppDelegate {
    func extoleShareAppInvalid() {
        DispatchQueue.main.async {
            self.delegate?.santaIsBusy()
        }
    }
    
    func extoleShareAppReady() {
        DispatchQueue.main.async {
             self.delegate?.santaIsReady()
        }
    }
}

