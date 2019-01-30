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
    
    var extoleApp = ExtoleApp.default
    
    @IBAction func doShare(_ sender: UIButton) {
        let recepient = recepientText.text
        let message = messageText.text
        extoleApp.share(recepient: recepient!, message: message!)
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
        }
    }
    
    @objc private func stateChanged(_ notification: Notification) {
        guard let extoleApp = notification.object as? ExtoleApp else {
            return
        }
        showState(app: extoleApp)
    }

}
