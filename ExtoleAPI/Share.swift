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
        -> APIResponse<CustomSharePollingResult> {
            let url = URL(string: "\(baseUrl)/api/v5/custom/share")!
            let shareData = try? JSONEncoder().encode(share)
            let pollingResponse : PollingIdResponse?
            pollingResponse = dataTask(url: url, accessToken: accessToken.access_token, postData: shareData).await(timeout: DispatchTime.now() + .seconds(100))
            return pollCustomShare(accessToken: accessToken, pollingResponse: pollingResponse!)
    }

    private func pollCustomShare(accessToken: ConsumerToken, pollingResponse: PollingIdResponse)
        -> APIResponse<CustomSharePollingResult> {
            let response = APIResponse<CustomSharePollingResult>.init()
            
            let url = URL(string: "\(baseUrl)/api/v5/custom/share/status/\(pollingResponse.polling_id)")!
            var polingResult:CustomSharePollingResult? = dataTask(url: url, accessToken: accessToken.access_token, postData: nil)
                .await(timeout: DispatchTime.now() + .seconds(5))
            var polingStatus = polingResult?.status
            for _ in 0..<10 {
                if polingStatus == "SUCCEEDED" {
                    response.setData(data: polingResult!)
                    return response;
                }
                sleep(1)
                polingResult = dataTask(url: url, accessToken: accessToken.access_token, postData: nil)
                    .await(timeout: DispatchTime.now() + .seconds(5))
                polingStatus = polingResult?.status
            }
            response.setError(error: ExtoleClientError.pollingTimeout)
            return response
    }

}
