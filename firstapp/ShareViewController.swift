//
//  ShareViewController.swift
//  firstapp
//
//  Created by rtibin on 1/25/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

import UIKit

class ShareViewController: UIViewController {
    @IBOutlet weak var recepientText: UITextField!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var messageText: UITextView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var shareLink: UITextField!
    
    var extoleApp = ExtoleApp.default
    
    @IBAction func doShare(_ sender: UIButton) {
       
        let message = messageText.text
        if let recepient = recepientText.text, !recepient.isEmpty {
            extoleApp.share(recepient: recepient, message: message!)
        } else {
            let shareItem = ShareItem.init(subject: "Check this out",
                                           message: messageText.text!,
                                           shortMessage: shareLink.text!)
            let textToShare = [ shareItem  ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
            activityViewController.completionWithItemsHandler =  {(activityType : UIActivity.ActivityType?, completed : Bool, returnedItems: [Any]?, activityError : Error?) in
                if let completedActivity = activityType, completed {
                    switch(completedActivity) {
                        case UIActivity.ActivityType.mail : do {
                           self.extoleApp.signalEmailShare()
                        }
                        case UIActivity.ActivityType.message : do {
                            self.extoleApp.signalMessageShare()
                        }
                        case UIActivity.ActivityType.postToFacebook : do {
                            self.extoleApp.signalFacebookShare()
                        }
                        default : do {
                            self.extoleApp.signalShare(channel: completedActivity.rawValue)
                        }
                    }
                    
                }
            }

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extoleApp.notification.addObserver(self, selector: #selector(stateChanged),
                                           name: NSNotification.Name.state, object: nil)
        showState(app: extoleApp)
    }
    
    func showState(app: ExtoleApp) {
        DispatchQueue.main.async {
            self.stateLabel.text = "State \(app.state)"
            switch app.state {
                case .ReadyToShare : do {
                    self.shareLink.text = app.selectedShareable?.link
                }
                default: do {
                    self.shareLink.isEnabled = false
                }
            }
        }
    }
    
    @objc private func stateChanged(_ notification: Notification) {
        guard let extoleApp = notification.object as? ExtoleApp else {
            return
        }
        showState(app: extoleApp)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc class ShareItem : NSObject, UIActivityItemSource {
        let message: String
        let shortMessage: String
        let subject: String
        init (subject: String, message: String, shortMessage: String) {
            self.subject = subject
            self.message = message
            self.shortMessage = shortMessage
        }
        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            return shortMessage
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            switch activityType {
                case UIActivity.ActivityType.message: return shortMessage
                default: return message
            }
            return message
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
            return subject
        }
    }
}
