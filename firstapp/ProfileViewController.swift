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
    var shareController : ShareViewController!
    var profileController: ProfileViewController!
    var historyController: HistoryViewController!

    init(with extoleApp: ExtoleApp) {
        self.extoleApp = extoleApp
        shareController = ShareViewController(with: extoleApp)
        historyController = HistoryViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var emailText: UITextField!
    
    var firstNameText: UITextField!
    
    var lastNameText: UITextField!
    
    @objc func profileChanged(_ sender: UITextField) {
        let updatedProfile = MyProfile.init(email: emailText.text,
                                            first_name: firstNameText.text,
                                            last_name: lastNameText.text,
                                            partner_user_id: nil)
        extoleApp?.updateProfile(profile: updatedProfile)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc private func stateChanged(_ notification: Notification) {
        guard let extoleApp = notification.object as? ExtoleApp else {
            return
        }
        showState(app: extoleApp)
    }
    
    func showState(app: ExtoleApp) {
        DispatchQueue.main.async {
            switch(app.state) {
                case .LoggedOut: do {
                    let newSession = UIBarButtonItem.init(title: "New Session", style: .plain, target: self, action: #selector(self.newSessionClick))
                    self.navigationItem.rightBarButtonItem = newSession
                    self.emailText.text = nil
                    self.firstNameText.text = nil
                    self.lastNameText.text = nil
                    self.navigationItem.leftBarButtonItem = nil
                }
                case .ReadyToShare : do {
                    let next = UIBarButtonItem.init(title: "Next", style: .plain, target: self, action: #selector(self.nextClick))
                    self.navigationItem.rightBarButtonItem = next
                }
                default : do {
                    if let profile = app.profile {
                        self.emailText.text = profile.email
                        self.firstNameText.text = profile.first_name
                        self.lastNameText.text = profile.last_name
                    }
                    let logout = UIBarButtonItem.init(title: "\(app.state)", style: .plain, target: self, action: #selector(self.logoutClick))
                    self.navigationItem.leftBarButtonItem = logout
                    self.navigationItem.rightBarButtonItem = nil
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
    
    @objc func nextClick(_ sender: UIButton) {
        navigationController?.pushViewController(shareController, animated: true)
    }
    
    @objc func logoutClick(_ sender: UIButton) {
        let logoutConfimation = UIAlertController(title: "Logout", message: "Confirm logout.", preferredStyle: .actionSheet)
        
        logoutConfimation.addAction(UIAlertAction(title: NSLocalizedString("Yes, Log me out", comment: "Default action"), style: .destructive, handler: { _ in
            self.extoleApp.logout()
        }))
        logoutConfimation.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: nil))
        self.present(logoutConfimation, animated: true, completion: nil)
    }
    
    @objc func newSessionClick(_ sender: UIButton) {
        extoleApp.newSession()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Advocate"
        self.view.backgroundColor = UIColor.white
        
        let emailLabel = newLabel(parentView: view, text: "Email:")
        emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        emailLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        emailLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        emailText = newText(parentView: view, placeholder: "me@email.com")
        emailText.autocapitalizationType = .none
        emailText.topAnchor.constraint(equalTo: emailLabel.topAnchor).isActive = true
        emailText.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor).isActive = true
        emailText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        emailText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        emailText.addTarget(self, action: #selector(profileChanged), for: .editingDidEnd)
        //
        let firstNameLabel = newLabel(parentView: view, text: "FirstName:")
        firstNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        firstNameLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        firstNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        firstNameLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true

        firstNameText =  newText(parentView: view, placeholder: "Joe")
        firstNameText.topAnchor.constraint(equalTo: firstNameLabel.topAnchor).isActive = true
        firstNameText.leadingAnchor.constraint(equalTo: firstNameLabel.trailingAnchor).isActive = true
        firstNameText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        firstNameText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        firstNameText.addTarget(self, action: #selector(profileChanged), for: .editingDidEnd)
        
        //
        let lastNameLabel = newLabel(parentView: view, text: "LastName:")
        lastNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lastNameLabel.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor).isActive = true
        lastNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        lastNameLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        lastNameText = newText(parentView: view, placeholder: "Doe")
        lastNameText.topAnchor.constraint(equalTo: lastNameLabel.topAnchor).isActive = true
        lastNameText.leadingAnchor.constraint(equalTo: lastNameLabel.trailingAnchor).isActive = true
        lastNameText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        lastNameText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        lastNameText.addTarget(self, action: #selector(profileChanged), for: .editingDidEnd)
        
        extoleApp.notification.addObserver(self, selector: #selector(stateChanged),
                                                   name: NSNotification.Name.state, object: nil)
        showState(app: extoleApp)
        
    }
    
  
    
}

