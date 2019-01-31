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
    var error: ExtoleError?
    let waitGroup : DispatchGroup
    
    let completeLock = DispatchQueue(label: "com.extole.APIResponse")
    var complete: ((_ : T?) -> Void)?
    var errorHandler: ((_ : ExtoleError) -> Void)?
    
    init() {
        waitGroup = DispatchGroup.init()
        waitGroup.enter()
    }
    
    func setData(data: T) -> Void{
        self.data = data
        completeLock.sync {
            if let onComplete = complete {
                onComplete(data)
            }
        }
        
        waitGroup.leave()
    }
    
    func setError(error: ExtoleError) -> Void{
        Logger.Error(message: "API error \(error)")
        self.error = error
        completeLock.sync {
            if let onError = errorHandler {
                onError(error)
            }
        }
        waitGroup.leave()
    }
    
    func onComplete(callback: @escaping (_ : T?) -> Void) -> Self {
        completeLock.sync {
            self.complete = callback
            if let dataComplete = data {
                callback(dataComplete)
            }
        }
        return self
    }
    
    func onError(errorHandler: @escaping (_ : ExtoleError) -> Void) -> Self {
        completeLock.sync {
            self.errorHandler = errorHandler
            if let existingError = error {
                errorHandler(existingError)
            }
        }
        return self
    }
    
    public func await(timeout: DispatchTime) -> T? {
        waitGroup.wait(timeout: timeout)
        return self.data
    }
}
