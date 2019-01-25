//
//  ExtoleApp.swift
//  firstapp
//
//  Created by rtibin on 1/25/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

class ExtoleApp {
    
    let program = Program.init(baseUrl: "https://roman-tibin-test.extole.com")
    
    let settings = UserDefaults.init()
    
    static let `default` = ExtoleApp()
    
    var savedToken : String? {
        get {
            return settings.string(forKey: "extole.access_token")
        }
        set(newSavedToken) {
            settings.set(newSavedToken, forKey: "extole.access_token")
        }
    }
}
