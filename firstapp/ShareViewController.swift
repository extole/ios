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
    var stateLabel: UILabel!
    
    var recepientText: UITextField!
    
    var messageText: UITextView!
    
    var shareButton: UIButton!
    
    var shareLink: UITextField!
    
    var extoleApp: ExtoleApp!
    
    @objc func doShare(_ sender: UIButton) {
       
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
    
    func newLabel(parentView: UIView, text: String) -> UILabel {
        let newLabel = UILabel()
        parentView.addSubview(newLabel)
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        newLabel.text = text
        return newLabel
    }
    
    func newText(parentView: UIView, placeholder: String) -> UITextField {
        let newText = UITextField()
        parentView.addSubview(newText)
        newText.translatesAutoresizingMaskIntoConstraints = false
        newText.placeholder = placeholder
        return newText
    }
    
    func newTextView(parentView: UIView) -> UITextView {
        let newText = UITextView()
        parentView.addSubview(newText)
        newText.translatesAutoresizingMaskIntoConstraints = false
        return newText
    }
    
    func newButton(parentView: UIView, text: String) -> UIButton {
        let newButton = UIButton()
        parentView.addSubview(newButton)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.setTitle(text, for: .normal)
        newButton.backgroundColor = .blue
        return newButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Share Link"
        
        let headerView = UIView()
        self.view.addSubview(headerView)
        
        headerView.backgroundColor = .white
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier :1 ).isActive = true
        headerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1).isActive = true
        
        stateLabel = newLabel(parentView: headerView, text: "State:")
        stateLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        stateLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        stateLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 1).isActive = true
        stateLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true
        
        
        let recepientLabel = newLabel(parentView: headerView, text: "Recepient:")
        recepientLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        recepientLabel.topAnchor.constraint(equalTo: stateLabel.bottomAnchor).isActive = true
        recepientLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5).isActive = true
        recepientLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true
        
        recepientText = newText(parentView: headerView, placeholder: "friend@email.com")
        recepientText.leadingAnchor.constraint(equalTo: recepientLabel.trailingAnchor).isActive = true
        recepientText.topAnchor.constraint(equalTo: recepientLabel.topAnchor).isActive = true
        recepientText.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5).isActive = true
        recepientText.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true
        
        messageText = newTextView(parentView: headerView)
        messageText.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        messageText.topAnchor.constraint(equalTo: recepientLabel.bottomAnchor).isActive = true
        messageText.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 1).isActive = true
        messageText.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.3).isActive = true
        messageText.text = "Check this out"
        
        shareLink = newText(parentView: headerView, placeholder: "your share link")
        shareLink.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        shareLink.topAnchor.constraint(equalTo: messageText.bottomAnchor).isActive = true
        shareLink.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 1).isActive = true
        shareLink.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true
        
        shareButton = newButton(parentView: headerView, text: "Share!")
        shareButton.topAnchor.constraint(equalTo: shareLink.bottomAnchor).isActive = true
        shareButton.leadingAnchor.constraint(equalTo: recepientLabel.trailingAnchor).isActive = true
        shareButton.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5).isActive = true
        shareButton.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true
        shareButton.addTarget(self, action: #selector(doShare), for: UIControl.Event.touchUpInside)
        
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
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
            return subject
        }
    }
}
