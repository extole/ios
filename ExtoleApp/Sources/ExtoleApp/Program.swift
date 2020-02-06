//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

extension ExtoleApp {
    public class Program {
        let sessionManager: SessionManager
        let label: String?
        var mobileSharing: MobileSharing?
        
        init(sessionManager: SessionManager, label: String?) {
            self.sessionManager = sessionManager
            self.label = label
        }
        
        func load(complete: @escaping (_ mobileSharing: MobileSharing) -> Void) -> Void {
            if let existingSharing = mobileSharing {
                complete(existingSharing)
            } else {
                var data : [String:String] = [:]
                if let programLabel = label {
                    data["labels"] = programLabel
                }
                sessionManager.loadMobileSharing(data: data,
                                                 success: { loadedSharing in
                   self.mobileSharing = loadedSharing
                   complete(loadedSharing)
               })
            }
        }
    
        public func share(data: [String:String],
                          success: @escaping (ExtoleAPI.Events.SubmitEventResponse) -> Void,
                          error: @escaping (ExtoleAPI.Error) -> Void) {
            self.load(complete: { loadedSharing in
                var shareDataWithCode : [String: String] = [:];
                if let shareCode = loadedSharing.me.share_code {
                   shareDataWithCode["share.advocate_code"] = shareCode
                }
                shareDataWithCode.merge(data, uniquingKeysWith: { left, right in
                   return left
                })
                self.sessionManager.async { session in
                    session.submitEvent(eventName: "shared",
                    data: shareDataWithCode,
                    success: success,
                    error: error)
                }
            })
        }
    }
}

extension ExtoleApp.SessionManager {
    public func getProgram(label: String? = nil) -> ExtoleApp.Program {
        return ExtoleApp.Program(sessionManager: self, label: label)
    }
}
