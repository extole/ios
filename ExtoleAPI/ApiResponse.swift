//
//  ApiResponse.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public class APIResponse<T: Codable> {
    var data: T?
    var error: Error?
    let waitGroup : DispatchGroup
    init() {
        waitGroup = DispatchGroup.init()
        waitGroup.enter()
    }
    
    func setData(data: T) -> Void{
        self.data = data
        waitGroup.leave()
    }
    
    func setError(error: Error) -> Void{
        Logger.Error(message: "API error \(error)")
        self.error = error
        waitGroup.leave()
    }
    
    public func await(timeout: DispatchTime) -> T? {
        waitGroup.wait(timeout: timeout)
        return self.data
    }
}
