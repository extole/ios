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
            // set up activity view controller
            let textToShare = [ self.extoleApp.selectedShareable?.link  ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)

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

}
