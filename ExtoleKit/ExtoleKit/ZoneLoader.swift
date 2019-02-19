//Copyright © 2019 Extole. All rights reserved.

import Foundation

public final class ZoneLoader<T: Codable> : Loader {
    let session: ProgramSession
    let zoneName: String
    public private(set) var zoneData: T? = nil
    
    public init(session: ProgramSession, zoneName: String) {
        self.session = session
        self.zoneName = zoneName
    }
    
    public func load(complete: @escaping () -> Void) {
        self.session.fetchObject(zone: zoneName, success: { (zoneData:T?) in
            self.zoneData = zoneData
            complete()
        }) { error in
            complete()
        }
    }
}
