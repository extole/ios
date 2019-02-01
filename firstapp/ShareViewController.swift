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
    var messageText: UITextView!
    
    var shareLink: UITextField!
    
    var extoleApp: ExtoleApp!
    
    init(with extoleApp: ExtoleApp) {
        self.extoleApp = extoleApp
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doShare(_ sender: UIButton) {
        let message = messageText.text

        let shareItem = ShareItem.init(subject: "Check this out",
                                       message: message!,
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
        self.view.backgroundColor = UIColor.white
        let primary = UIBarButtonItem.init(barButtonSystemItem: .action, target: self
            , action: #selector(doShare))
        navigationItem.rightBarButtonItem = primary
        
        let messageLabel = newLabel(parentView: view, text: "Message:")
        messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        messageLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        messageLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        messageText = newTextView(parentView: view)
        messageText.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        messageText.topAnchor.constraint(equalTo: messageLabel.bottomAnchor).isActive = true
        messageText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        messageText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        messageText.text = "Check this out"
        
        shareLink = newText(parentView: view, placeholder: "your share link")
        shareLink.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        shareLink.topAnchor.constraint(equalTo: messageText.bottomAnchor).isActive = true
        shareLink.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        shareLink.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        /*
        let toolbar = UIToolbar.init()
        view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolbar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        toolbar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        let space = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let actionButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self
            , action: #selector(doShare))
        toolbar.items = [space, actionButton]
        view.addSubview(toolbar)
        */
        
        ExtoleApp.default.notification.addObserver(self, selector: #selector(stateChanged),
                                           name: NSNotification.Name.state, object: nil)
        showState(app: extoleApp)
    }
    
    func showState(app: ExtoleApp) {
        DispatchQueue.main.async {
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
