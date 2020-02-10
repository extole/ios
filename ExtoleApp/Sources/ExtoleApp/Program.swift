//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

extension ExtoleApp {
    public class Program {
        public let sessionManager: SessionManager
        let labels: String?
        var mobileSharing: AdvocateMobileExperience?
        
        init(sessionManager: SessionManager, labels: String?) {
            self.sessionManager = sessionManager
            self.labels = labels
        }
        
        public func ready(complete: @escaping (_ mobileSharing: AdvocateMobileExperience) -> Void) -> Void {
            if let existingSharing = mobileSharing {
                complete(existingSharing)
            } else {
                var data : [String:String] = [:]
                if let selectedLabels = labels {
                    data["labels"] = selectedLabels
                }
                sessionManager.loadAdvocateExeprience(data: data,
                                                 success: { loadedSharing in
                   self.mobileSharing = loadedSharing
                   complete(loadedSharing)
               })
            }
        }
    
        public func share(data: [String:String],
                          success: @escaping (ExtoleAPI.Events.SubmitEventResponse) -> Void,
                          error: @escaping (ExtoleAPI.Error) -> Void) {
            self.ready(complete: { loadedSharing in
                var shareDataWithCode : [String: String] = [:];
                if let shareCode = loadedSharing.me.advocate_code {
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
    public func program(labels: String? = nil) -> ExtoleApp.Program {
        return ExtoleApp.Program(sessionManager: self, labels: labels)
    }
}
