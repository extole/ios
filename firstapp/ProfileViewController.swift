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
    
    @IBAction func shareClick(_ sender: UIButton) {
    }
    
    @IBAction func profileChanged(_ sender: UITextField) {
        let updatedProfile = MyProfile.init(email: emailText.text,
                                            first_name: firstNameTesxt.text,
                                            last_name: lastNameText.text,
                                            partner_user_id: nil)
        program.updateProfile(accessToken: accessToken!, profile: updatedProfile).onComplete(callback: {_ in Logger.Info(message: "Updated \(updatedProfile)")
            DispatchQueue.main.async {
                self.nextButton.isEnabled = true
            }
        })
    }
    
    let program = Program.init(baseUrl: "https://roman-tibin-test.extole.com")
    
    var accessToken: ConsumerToken?
    
    func showAccessToken(text: String) {
        DispatchQueue.main.async {
            self.accessTokenLabel.text = text
        }
    }
    
    func showProfile(profile: MyProfile) {
        DispatchQueue.main.async {
            self.emailText.text = profile.email
            self.firstNameTesxt.text = profile.first_name
            self.lastNameText.text = profile.last_name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false
        let dispatchQueue = DispatchQueue(label : "Extole", qos:.background)
        dispatchQueue.async {
            self.showAccessToken(text: "Fetching access Token...")
            self.accessToken = self.program.getToken().await(timeout: DispatchTime.now() + .seconds(10))
            if let accessToken = self.accessToken {
                self.showAccessToken(text: "Token: \(accessToken.access_token)")
                let profile = self.program.getProfile(accessToken: accessToken)
                    .await(timeout: DispatchTime.now() + .seconds(10))
                if let profile = profile {
                    self.showProfile(profile: profile)
                }
            } else {
                self.showAccessToken(text: "No Token")
            }
        }
    }
    
}

