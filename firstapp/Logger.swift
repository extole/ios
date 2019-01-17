//
//  Logger.swift
//  firstapp
//
//  Created by rtibin on 1/17/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public class Logger {
    
    static func Info(message : String) {
        print("INFO : \(message)")
    }
    
    static func Error(message : String) {
        print("ERROR : \(message)")
    }
}
