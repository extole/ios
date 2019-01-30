//
//  ViewController.swift
//  firstapp
//
//  Created by rtibin on 1/11/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var accessTokenLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var firstNameTesxt: UITextField!
    
    @IBOutlet weak var lastNameText: UITextField!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBAction func shareClick(_ sender: UIButton) {
    }
    
    @IBAction func profileChanged(_ sender: UITextField) {
        let updatedProfile = MyProfile.init(email: emailText.text,
                                            first_name: firstNameTesxt.text,
                                            last_name: lastNameText.text,
                                            partner_user_id: nil)
        extoleApp.updateProfile(profile: updatedProfile)
    }
    
    var extoleApp = ExtoleApp.default
    
    func showAccessToken(text: String) {
        DispatchQueue.main.async {
            self.accessTokenLabel.text = text
        }
    }
    
    @objc private func stateChanged(_ notification: Notification) {
        guard let extoleApp = notification.object as? ExtoleApp else {
            return
        }
        showState(app: extoleApp)
    }
    
    func showState(app: ExtoleApp) {
        DispatchQueue.main.async {
            self.stateLabel.text = "State \(app.state)"
            self.accessTokenLabel.text = app.savedToken
            
            if let profile = app.profile {
                self.emailText.text = profile.email
                self.firstNameTesxt.text = profile.first_name
                self.lastNameText.text = profile.last_name
                if let _ = profile.email {
                    self.nextButton.isEnabled = true
                }
            } else {
                self.nextButton.isEnabled = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        extoleApp.notification.addObserver(self, selector: #selector(stateChanged),
                                                   name: NSNotification.Name.state, object: nil)
        showState(app: extoleApp)
    }
    
}

