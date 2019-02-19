//Copyright © 2019 Extole. All rights reserved.

import Foundation

open class ExtoleShareApp : ExtoleApp {
    public private(set) var profileLoader: ProfileLoader!
    public private(set) var shareableLoader: ShareableLoader!
    public private(set) var settingsLoader: ZoneLoader<ShareSettings>!
    let label : String
    
    private init(program: Program, label: String){
        self.label = label
        super.init(with: program)
    }
    
    public convenience init(programUrl: URL, label: String) {
        self.init(program: Program(baseUrl: programUrl), label: label)
        profileLoader = ProfileLoader() { _ in
        }
        
        settingsLoader = ZoneLoader(zoneName: "settings")
        shareableLoader = ShareableLoader(success: shareablesLoaded)
        
        let composite = CompositeLoader(loaders: [profileLoader!, settingsLoader!, shareableLoader!])
        self.initSessionManager(preloader: composite, observer: observer)
    }
    
    public func signalShare(channel: String,
                            success: @escaping (CustomSharePollingResult?)->Void,
                            error: @escaping(ExtoleError) -> Void) {
        extoleInfo(format: "shared via custom channel %s", arg: channel)
        
        if let session = sessionManager.session, let shareableCode = self.selectedShareableCode{
            let share = CustomShare.init(advocate_code: shareableCode, channel: channel)
            session.customShare(share: share, success: { pollingResponse in
                session.pollCustomShare(pollingResponse: pollingResponse!,
                                        success: success, error: error)
            }, error: error)
        }
    }
    
    public func share(email: String,
                      success: @escaping (EmailSharePollingResult?)->Void,
                      error: @escaping(ExtoleError) -> Void) {
        extoleInfo(format: "sharing to email %s", arg: email)
        if let session = sessionManager.session, let shareableCode = self.selectedShareableCode {
            let share = EmailShare.init(advocate_code: shareableCode,
                                        recipient_email: email)
            session.emailShare(share: share, success: { pollingResponse in
                session.pollEmailShare(pollingResponse: pollingResponse!,success:success, error: error)
            }, error: error)
        }
    }
    
    public func updateProfile(profile: MyProfile,
                              success: @escaping () -> Void,
                              error : @escaping (UpdateProfileError) -> Void) {
        self.sessionManager.session?.updateProfile(profile: profile, success: success, error: error)
    }
    
    public var selectedShareable: MyShareable? {
        get {
            return shareableLoader?.shareables?.filter({ shareable in
                shareable.code == selectedShareableCode
            }).first
        }
    }
    
    func shareablesLoaded(shareables: [MyShareable]?) {
        if let shareable = self.selectedShareable {
            extoleInfo(format: "re-using previosly selected shareable %s", arg: shareable.code)
        } else {
            self.selectedShareableCode = nil
            let uniqueKey = NSUUID().uuidString
            let newShareable = MyShareable.init(label: self.label, key: uniqueKey)
            self.sessionManager.session?.createShareable(shareable: newShareable, success: { pollingId in
                self.sessionManager.session?.pollShareable(pollingResponse: pollingId!,
                                            success: { shareableResult in
                                                self.selectedShareableCode = shareableResult?.code
                                                self.shareableLoader?.load(session: self.sessionManager.session!){}
                }, error: {_ in
                    
                })
            }, error : { _ in
                
            })
        }
    }
}

public struct ShareSettings : Codable {
    public let shareMessage: String
}
