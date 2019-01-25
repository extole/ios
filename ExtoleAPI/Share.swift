//
//  Share.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public struct CustomShare : Codable {
    let advocate_code: String
    let channel: String
    let message: String
    let recipient_email: String
    let data: [String:String]
}

public struct CustomSharePollingResult : Codable {
    let polling_id : String
    let status : String
    let share_id : String
}

extension Program {
    
    public func customShare(accessToken: ConsumerToken, share: CustomShare)
        -> APIResponse<PollingIdResponse> {
        let url = URL(string: "\(baseUrl)/api/v5/custom/share")!
        let shareData = try? JSONEncoder().encode(share)
        return dataTask(url: url, accessToken: accessToken.access_token, postData: shareData)
    }

    public func pollCustomShare(accessToken: ConsumerToken, pollingResponse: PollingIdResponse)
        -> APIResponse<CustomSharePollingResult> {
            let response = APIResponse<CustomSharePollingResult>.init()
            let url = URL(string: "\(baseUrl)/api/v5/custom/share/status/\(pollingResponse.polling_id)")!
            
            func poll(retries: UInt = 10) {
                dataTask(url: url, accessToken: accessToken.access_token, postData: nil)
                    .onComplete { (pollingResult: CustomSharePollingResult?) in
                        let polingStatus = pollingResult?.status
                        if polingStatus == "SUCCEEDED" {
                            response.setData(data: pollingResult!)
                        } else if retries > 0 {
                            sleep(1)
                            poll(retries: retries - 1)
                        } else {
                            response.setError(error: ExtoleClientError.pollingTimeout)
                        }
                }
            }
            
            poll(retries: 10)
            
            return response
    }

}
