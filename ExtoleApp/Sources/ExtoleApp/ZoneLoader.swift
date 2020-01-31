//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

/// Loads Extole zone as JSON
public final class ZoneLoader<T: Codable> : Loader {
    let zoneName: String
    public private(set) var zoneData: T? = nil
    
    public init(zoneName: String) {
        self.zoneName = zoneName
    }
    
    public func load(session: ExtoleAPI.Session, complete: @escaping () -> Void) {
        session.renderZone(eventName: zoneName, success: { (zoneData:T?) in
            self.zoneData = zoneData
            complete()
        }) { error in
            complete()
        }
    }
}
