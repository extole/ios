import Foundation
import ExtoleMobileSDK

class ExtoleCampaign: ObservableObject {
    @Published var cta = CTA()
    var contextCampaign: Campaign?
    var extole: ExtoleSDK = ExtoleSDK()

    func fetch() {
        /*extole.fetchZone("cta_prefetch", [:]) { (zone: ExtoleMobileSDK.Zone?, _: ExtoleMobileSDK.Campaign?, error: Error?) in
            let title = zone?.get("title") as! String? ?? ""
            let touchEvent = zone?.get("touch_event") as! String? ?? ""
            let image = zone?.get("image") as! String? ?? ""
            self.cta = CTA(text: title, image: image, touchEvent: touchEvent)
        }*/
    }

    public func getWebView(zoneName: String) -> UIExtoleWebView? {
        return nil
        if nil != contextCampaign {
            //return UIExtoleWebView(contextCampaign!.webView(), zoneName)
        } else {
            //return UIExtoleWebView(extole.webView(), zoneName)
        }
    }
}
