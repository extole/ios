//Copyright © 2019 Extole. All rights reserved.

import UIKit
import WebKit
import FBSDKShareKit

let programUrl = URL(string:"https://ios-santa.extole.io/zone/microsite")

func openExternal(url: URL) {
    UIApplication.shared.open(url,
                              options: [:],
                              completionHandler: {success in
                                print("openExternal", url, success)
    })
    
}

class ViewController: UIViewController {

    var topView: WKWebView!
    var popupView: WKWebView?
    
    var popupDelegate: PopupDelegate?
    
    func closePopup() {
        self.popupView?.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WebView Example"
        let top =  UIApplication.shared.statusBarFrame.height
        let rect = CGRect(x: 0, y:  top, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let topViewDelegate = self
        self.popupDelegate  = PopupDelegate()
        self.popupDelegate?.topViewController = self
        
        topView = WKWebView(frame: rect)
        self.view.addSubview(topView)
        topView.navigationDelegate = topViewDelegate
        topView.uiDelegate = topViewDelegate
        
        var myRequest = URLRequest(url: programUrl!)
        if UIApplication.shared.canOpenURL(URL(string:"whatsapp://app")!) {
            myRequest.addValue("native", forHTTPHeaderField: "whatapps_available")
        }
        if UIApplication.shared.canOpenURL(URL(string:"fbauth2://")!){
            myRequest.addValue("native", forHTTPHeaderField: "facebook_available")
        }
        topView.load(myRequest)
    }
}

class PopupDelegate : NSObject, WKUIDelegate, WKNavigationDelegate {
    var topViewController: ViewController?
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("checking policy for : ", navigationAction.request.url ?? "(none)")
        let external = [
            "https://api.whatsapp.com/send": {
                guard var urlComponents = URLComponents(string: navigationAction.request.url!.absoluteString) else {return}
                urlComponents.scheme = "whatsapp"
                urlComponents.host = "send"
                urlComponents.path = ""
                openExternal(url: urlComponents.url!)

                self.topViewController?.closePopup()
                decisionHandler(.cancel)
                
            },
            "https://www.facebook.com/dialog": {
                // note Info.plist changes https://developers.facebook.com/docs/ios/getting-started/
                // CFBundleURLTypes - should include fb{your-app-id}
                // FacebookAppID - {your-app-id}
                // FacebookDisplayName - - {your-app-name}
                // Link with Facebook SDK libraries : https://developers.facebook.com/docs/ios/componentsdks
                // FBSDKCoreKit, FBSDKShareKit
                let facebookComponents = URLComponents(url: navigationAction.request.url!,
                                               resolvingAgainstBaseURL: false)
                let hrefValue = facebookComponents?.queryItems?.filter({ qItem -> Bool in
                    return qItem.name == "href"
                }).first?.value ?? "https://santa.extole.io"
            
                let facebookContent = FBSDKShareLinkContent.init()
                
                facebookContent.contentURL = URL(string: hrefValue)
                let dialog = FBSDKShareDialog.init()
                dialog.fromViewController = self.topViewController
                dialog.shareContent = facebookContent;
                
                if UIApplication.shared.canOpenURL(URL(string:"fbauth2://")!){
                    dialog.mode = .native
                } else {
                    dialog.mode = .browser
                }
                dialog.show()
                self.topViewController?.closePopup()
                decisionHandler(.cancel)
            }]
        let externalMatch = external.filter { pattern -> Bool in
            return navigationAction.request.url?.absoluteString.starts(with: pattern.key) ?? false
        }.first
        if let externalMatch = externalMatch {
            externalMatch.value()
        } else {
            decisionHandler(.allow)
        }
    }
}

extension ViewController : WKUIDelegate, WKNavigationDelegate {
    // handles window.open
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("create web view for", navigationAction.request)
        let rect = CGRect(x: 0, y:  UIScreen.main.bounds.height / 4, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2 )
        self.popupView = WKWebView(frame: rect, configuration: configuration)   // Must use the configuration provided by this method
        self.popupView?.navigationDelegate = self.popupDelegate
        self.popupView?.uiDelegate = self.popupDelegate
        view.addSubview(self.popupView!)
        
        return popupView
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("check policy : ", navigationAction.request.url ?? "(none)")
        if navigationAction.request.url?.scheme == "sms" {
            openExternal(url: navigationAction.request.url!)
            decisionHandler(.cancel)
        } else {
            
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("allow response", navigationResponse.response.url ?? "(none)")
        decisionHandler(.allow)
    }
    //
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("nav error : ", error)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("prov error : ", error)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish : ", String(describing: navigation!))
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("commit : ", String(describing: navigation!))
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start : ", String(describing: navigation!))
    }
}
