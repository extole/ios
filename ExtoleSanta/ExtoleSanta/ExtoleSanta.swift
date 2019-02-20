//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleKit

protocol ExtoleSantaDelegate: class {
    func santaIsBusy()
    func santaIsReady()
}

class ExtoleSanta : ShareExperince {

    init(delegate: ExtoleSantaDelegate) {
        self.delegate = delegate
    }
    weak var delegate : ExtoleSantaDelegate?
    
    lazy var shareApp = ExtoleShareApp(programUrl: URL.init(string: "https://ios-santa.extole.io")!,
                                       programLabel: "refer-a-friend",
                                       delegate: self)
    
}

extension ExtoleSanta : ExtoleShareAppDelegate {
    func extoleShareAppBusy() {
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

