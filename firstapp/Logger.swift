//
//  Logger.swift
//  firstapp
//
//  Created by rtibin on 1/17/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation
import os.log

@available(iOS 10.0, *)
let appLog = OSLog.init(subsystem: "com.extole", category: "app")
