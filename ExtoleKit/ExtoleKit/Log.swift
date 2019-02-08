//
//  Log.swift
//  firstapp
//
//  Created by rtibin on 2/6/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

import os.log

@available(iOS 10.0, *)
let modelLog = OSLog.init(subsystem: "com.extole", category: "model")

public func extoleDebug(format: StaticString, arg: CVarArg? = nil) {
    if #available(iOS 10.0, *) {
        os_log(format, log: modelLog, type: OSLogType.debug, arg ?? "")
    } else {
        let openFormat = format.description
            .replacingOccurrences(of: "{public}", with: "")
            .replacingOccurrences(of: "{private}", with: "")
        NSLog("[DEBUG] ".appending(openFormat), arg ?? "")
    }
}

public func extoleInfo(format: StaticString, arg: CVarArg? = nil) {
    if #available(iOS 10.0, *) {
        os_log(format, log: modelLog, type: OSLogType.info, arg ?? "")
    } else {
        let openFormat = format.description
            .replacingOccurrences(of: "{public}", with: "")
            .replacingOccurrences(of: "{private}", with: "")
        NSLog("[INFO] ".appending(openFormat), arg ?? "")
    }
}
