import Foundation
import ExtoleMobileSDK

class ExtoleCampaign: ObservableObject {
    @Published var shareExperience = ExtoleShareExperience()
    var extole: Extole = ExtoleService(programDomain: "https://mobile-monitor.extole.io",
        applicationName: "iOS App", labels: ["business"])
    var contextCampaign: Campaign?

    func fetchExtoleProgram() {
        extole.getZone("apply_for_card") { (zone: ExtoleMobileSDK.Zone?, _: ExtoleMobileSDK.Campaign?, error: Error?) in
            if error != nil {
                self.shareExperience = ExtoleShareExperience(title: "Error",
                    shareButtonText: "...",
                    shareMessage: error?.localizedDescription ?? "Unable to load Extole Zone", shareImage: "...")
            } else {
                let shareImage = zone?.get("sharing.email.image") as! String? ?? ""
                let shareButtonText = zone?.get("sharing.email.subject") as! String? ?? ""
                let shareMessage = zone?.get("sharing.email.message") as! String? ?? ""
                self.shareExperience = ExtoleShareExperience(title: "Extole Sharing Program",
                    shareButtonText: shareButtonText,
                    shareMessage: shareMessage, shareImage: shareImage)
            }
        }
    }

    public func identify(email: String) {
        extole = extole.copy(email: email)
    }

    public func getWebView(zoneName: String) -> UIExtoleWebView {
        if nil != contextCampaign {
            return UIExtoleWebView(contextCampaign!.webView(), zoneName)
        } else {
            return UIExtoleWebView(extole.webView(), zoneName)
        }
    }
}
