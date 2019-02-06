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
    
    @objc func doneClick(_ sender: UITextField) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Share Link"
        self.view.backgroundColor = UIColor.white
        let done = UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(self.doneClick))
        self.navigationItem.rightBarButtonItem = done
        
        let messageLabel = view.newLabel(text: "Message:")
        messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            messageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        messageLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        messageLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        messageText = view.newTextView()
        messageText.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        messageText.topAnchor.constraint(equalTo: messageLabel.bottomAnchor).isActive = true
        messageText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        messageText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        messageText.text = "Check this out"
        
        shareLink = view.newText(placeholder: "your share link")
        shareLink.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        shareLink.topAnchor.constraint(equalTo: messageText.bottomAnchor).isActive = true
        shareLink.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        shareLink.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
