//Copyright © 2019 Extole. All rights reserved.

import UIKit
import WebKit

class ViewController: UIViewController {

    var webView: WKWebView!
    var webPopupView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WebView"
        let top =  UIApplication.shared.statusBarFrame.height
        let rect = CGRect(x: 0, y:  top, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        webView = WKWebView(frame: rect)
        self.view.addSubview(webView)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        let myURL = URL(string:"https://ios-santa.extole.io/zone/microsite")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("create web view for", navigationAction.request)
        if let popup = self.webPopupView {
            popup.removeFromSuperview()
        }
        let rect = CGRect(x: 0, y:  64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2 )
        self.webPopupView = WKWebView(frame: view.bounds, configuration: configuration)   // Must use the configuration provided by this method
        self.webPopupView?.navigationDelegate = self
        self.webPopupView?.uiDelegate = self
        self.view.addSubview(self.webPopupView!)
        //webView.removeFromSuperview()
        return webPopupView
    }
    func webViewDidClose(_ webView: WKWebView) {
        print("closed")
    }
}

extension ViewController: WKNavigationDelegate {
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
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        navigationResponse.response.url
        print("allow response", navigationResponse.response.url)
        decisionHandler(.allow)
    }
    
    func openExternal(url: URL) {
        UIApplication.shared.open(url,
                                  options: [:],
                                  completionHandler: {success in
                                    print("url sent", success)
        })
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.request.url!.absoluteString.starts(with: "https://api.whatsapp.com/send")) {
            openExternal(url: navigationAction.request.url!)
            decisionHandler(.cancel)
        } else if (navigationAction.request.url!.absoluteString.starts(with: "https://www.facebook.com/dialog")) {
            openExternal(url: navigationAction.request.url!)
            decisionHandler(.cancel)
        } else if navigationAction.request.url?.scheme == "sms" {
            UIApplication.shared.open(navigationAction.request.url!,
                                      options: [:],
                                      completionHandler: {success in
                                        print("sms sent", success)
            })
            decisionHandler(.cancel)
        } else if navigationAction.request.url?.scheme == "whatsapp" {
            UIApplication.shared.open(navigationAction.request.url!,
                                      options: [:],
                                      completionHandler: {success in
                    self.webPopupView?.removeFromSuperview();
                    self.webPopupView = nil
                    self.view.addSubview(self.webView)
                    
            })
            decisionHandler(.cancel)
        } else {
            print("allow policy : ", navigationAction.request.url)
            decisionHandler(.allow)
        }
    }
}

