//
//  Logger.swift
//  firstapp
//
//  Created by rtibin on 1/17/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation
import os.log

public class Logger {
    
    static let NetworkLog = OSLog.init(subsystem: "com.extole", category: "network")
    
    static let AppLog = OSLog.init(subsystem: "com.extole", category: "app")
}
