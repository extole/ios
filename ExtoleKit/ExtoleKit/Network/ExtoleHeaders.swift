//Copyright © 2019 Extole. All rights reserved.

import Foundation

func version(for bundle: Bundle) -> String {
    return bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "unknown"
}

func gitRevision(for bundle: Bundle) -> String {
    return bundle.object(forInfoDictionaryKey: "gitRevision") as? String ?? "unknown"
}

class ExtoleHeaders {
    static let all = [
        "X-Extole-App": "Mobile SDK",
        "X-Extole-App-flavour": "iOS-Swift",
        "X-Extole-Sdk-version": version(for: Bundle(for: ExtoleHeaders.self)),
        "X-Extole-Sdk-gitRevision": gitRevision(for: Bundle(for: ExtoleHeaders.self)),
        
        "X-Extole-App-version": version(for: Bundle.main),
        "X-Extole-App-appId": Bundle.main.bundleIdentifier ?? "unknown",
        "X-Extole-DeviceId": UIDevice.current.identifierForVendor?.uuidString ?? "unknown",
        ]
}
