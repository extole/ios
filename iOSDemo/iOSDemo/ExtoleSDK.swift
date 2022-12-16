import Foundation
import ExtoleMobileSDK

@objcMembers class ExtoleSDK: NSObject {
    static let shared = ExtoleSDK()
    var extole: Extole = ExtoleImpl(programDomain: "https://mobile-monitor.extole.io", applicationName: "ios-owner", listenToEvents: false) //TODO: programDomain: "share.wagwalking.com"
    
    func setup() {
        NSLog("Extole SDK: setup()" )
        self.identify()
    }
    
    func identify() {
        NSLog("Extole SDK: identify()")
        let email: String = ""
        let ownerId = ""
        self.extole.identify(email, ["owner_id": ownerId]) { (event: Id<Event>?, error: Error?) in
            NSLog("Extole SDK: identify(\"\(email)\", [\"owner_id\": \"\(ownerId)\"]) \(self.debugMessage(event, error))")
        }
    }
    
    func sendEvent(_ eventName: String, _ data: [String: Any?] = [:]) {
        NSLog("Extole SDK: sendEvent(\"\(eventName)\")")
        self.extole.sendEvent(eventName, data) { (event: Id<Event>?, error: Error?) in
            NSLog("Extole SDK: sendEvent(\"\(eventName)\") \(self.debugMessage(event, error))")
        }
    }
    private func debugMessage(_ event: Id<Event>?, _ error: Error?) -> String {
        if let error = error {
            return "Error: \(error.localizedDescription)"
        } else if let event = event {
            return event.getValue()
        } else {
            return "Failed"
        }
    }
}
