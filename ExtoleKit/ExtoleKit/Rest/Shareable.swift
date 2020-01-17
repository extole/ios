//Copyright © 2019 Extole. All rights reserved.

import Foundation

public struct PollingIdResponse : Codable {
    let polling_id : String
}

public struct ShareablePollingResult : Codable {
    public let polling_id : String
    public let status : String
    public let code : String?
}

public struct UpdateShareable : Codable {
    public init(data: [String: String]) {
        self.data = data
    }
    public let data: [String: String]?
}

@objc public final class MyShareable : NSObject, Codable {
    public init(label: String, code:String? = nil, key:String? = nil) {
        self.label = label
        self.code = code
        self.key = key
        self.link = nil
        self.data = nil
    }
    @objc public let key: String?
    @objc public let code: String?
    @objc public let label: String?
    @objc public let link: String?
    @objc public let data: [String: String]?
}

extension ProgramSession {
    public func getShareables(success: @escaping ([MyShareable]) -> Void,
                              error: @escaping (ExtoleError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables")!
        let request = self.getRequest(url: url)
        self.network.processRequest(with: request, success: success, error: error)
    }
    
    @objc public func getShareable(code: String, success: @escaping (MyShareable) -> Void,
                              error errorCallback: @escaping (ExtoleError) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/shareables/\(code)")!
        let request = self.getRequest(url: url)
        self.network.processRequest(with: request, success: success, error: { (error:ExtoleError) in
            errorCallback(error)
        })
    }
    
    public func updateShareable(code: String,
                                shareable: UpdateShareable,
                                success: @escaping () -> Void,
                                error : @escaping (ExtoleError) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables/\(code)")!
        let request = self.putRequest(url: url, data: shareable)
        self.network.processNoContentRequest(with: request, success: success, error: error)
    }

    public func createShareable(shareable: MyShareable,
                                success: @escaping (PollingIdResponse) -> Void,
                                error: @escaping (ExtoleError) -> Void)  {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables")!
        let request = self.postRequest(url: url, data: shareable)
        self.network.processRequest(with: request, success: success, error: error)
    }

    public func pollShareable(pollingResponse: PollingIdResponse,
                              success: @escaping (ShareablePollingResult) -> Void,
                              error: @escaping (ExtoleError) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables/status/\(pollingResponse.polling_id)")!

        let request = self.getRequest(url: url)
        self.network.processRequest(with: request, success: success, error: error)
    }
}
