//
//  ViewController.swift
//  firstapp
//
//  Created by rtibin on 1/11/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var extoleApp: ExtoleApp!
    
    var stateLabel: UILabel!
    
    var accessTokenLabel: UILabel!
    
    var emailText: UITextField!
    
    var firstNameText: UITextField!
    
    var lastNameText: UITextField!
    
    var nextButton: UIButton!
    
    let shareController = ShareViewController()
    
    @objc func shareClick(_ sender: UIButton) {
        shareController.extoleApp = self.extoleApp
        self.navigationController?.pushViewController(shareController, animated: true)
    }
    
    @IBAction func profileChanged(_ sender: UITextField) {
        let updatedProfile = MyProfile.init(email: emailText.text,
                                            first_name: firstNameText.text,
                                            last_name: lastNameText.text,
                                            partner_user_id: nil)
        extoleApp.updateProfile(profile: updatedProfile)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
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
        return
        DispatchQueue.main.async {
            self.stateLabel.text = "State \(app.state)"
            self.accessTokenLabel.text = app.savedToken
            
            if let profile = app.profile {
                self.emailText.text = profile.email
                self.firstNameText.text = profile.first_name
                self.lastNameText.text = profile.last_name
            }
            switch (app.state) {
                case .ReadyToShare : do {
                    self.nextButton.isEnabled = true
                }
                default : do {
                    self.nextButton.isEnabled = false
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
        
        self.navigationItem.title = "Advocate Profile"
        
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
        
        accessTokenLabel = newLabel(parentView: headerView, text: "Token:")
        accessTokenLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        accessTokenLabel.topAnchor.constraint(equalTo: stateLabel.bottomAnchor).isActive = true
        accessTokenLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 1).isActive = true
        accessTokenLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true
        //
        let emailLabel = newLabel(parentView: headerView, text: "Email:")
        emailLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        emailLabel.topAnchor.constraint(equalTo: accessTokenLabel.bottomAnchor).isActive = true
        emailLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5).isActive = true
        emailLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true
        
        emailText = newText(parentView: headerView, placeholder: "me@email.com")
        emailText.topAnchor.constraint(equalTo: accessTokenLabel.bottomAnchor).isActive = true
        emailText.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor).isActive = true
        emailText.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5).isActive = true
        emailText.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true
        emailText.addTarget(self, action: #selector(profileChanged), for: .editingDidEnd)
        //
        let firstNameLabel = newLabel(parentView: headerView, text: "FirstName:")
        firstNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        firstNameLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        firstNameLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5).isActive = true
        firstNameLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true

        firstNameText =  newText(parentView: headerView, placeholder: "Joe")
        firstNameText.topAnchor.constraint(equalTo: firstNameLabel.topAnchor).isActive = true
        firstNameText.leadingAnchor.constraint(equalTo: firstNameLabel.trailingAnchor).isActive = true
        firstNameText.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5).isActive = true
        firstNameText.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true
        firstNameText.addTarget(self, action: #selector(profileChanged), for: .editingDidEnd)
        
        //
        let lastNameLabel = newLabel(parentView: headerView, text: "LastName:")
        lastNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        lastNameLabel.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor).isActive = true
        lastNameLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5).isActive = true
        lastNameLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true
        
        lastNameText = newText(parentView: headerView, placeholder: "Doe")
        lastNameText.topAnchor.constraint(equalTo: lastNameLabel.topAnchor).isActive = true
        lastNameText.leadingAnchor.constraint(equalTo: lastNameLabel.trailingAnchor).isActive = true
        lastNameText.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5).isActive = true
        lastNameText.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true
        lastNameText.addTarget(self, action: #selector(profileChanged), for: .editingDidEnd)
        
        nextButton = newButton(parentView: headerView, text: "Next")
        nextButton.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: lastNameText.leadingAnchor).isActive = true
        nextButton.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5).isActive = true
        nextButton.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.1).isActive = true
        nextButton.isEnabled = false
        nextButton.addTarget(self, action: #selector(shareClick), for: UIControl.Event.touchUpInside)
        
        extoleApp.notification.addObserver(self, selector: #selector(stateChanged),
                                                   name: NSNotification.Name.state, object: nil)
        showState(app: extoleApp)
        
    }
    
}

