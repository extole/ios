//
//  IdentifyViewController.swift
//  firstapp
//
//  Created by rtibin on 2/4/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation
import UIKit

class IdentifyViewController: UIViewController {
    
    var extoleApp: ExtoleApp!
    
    var profileViewController: ProfileViewController!
    
    var emailText: UITextField!
    
    init(with extoleApp: ExtoleApp) {
        self.extoleApp = extoleApp
        self.profileViewController = ProfileViewController.init(with : extoleApp)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func nextClick(_ sender: UIButton) {
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Identify"
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
        
        emailText.addTarget(self, action: #selector(emailChanged), for: .editingDidEnd)
        
        extoleApp.notification.addObserver(self, selector: #selector(stateChanged),
                                           name: NSNotification.Name.state, object: nil)
        
        showState(app: extoleApp)
    }
    
    @objc private func stateChanged(_ notification: Notification) {
        guard let extoleApp = notification.object as? ExtoleApp else {
            return
        }
        showState(app: extoleApp)
    }
    
    func showState(app: ExtoleApp) {
        DispatchQueue.main.async {
            if let profile = app.profile, !(app.profile?.email?.isEmpty ?? true) {
                self.emailText.text = profile.email
                let next = UIBarButtonItem.init(title: "Next", style: .plain, target: self, action: #selector(self.nextClick))
                self.navigationItem.rightBarButtonItem = next
                let logout = UIBarButtonItem.init(title: "Logout", style: .plain, target: self, action: #selector(self.logoutClick))
                self.navigationItem.leftBarButtonItem = logout
            } else {
                let next = UIBarButtonItem.init(title: "Skip", style: .plain, target: self, action: #selector(self.nextClick))
                self.navigationItem.rightBarButtonItem = next
            }
        }
    }
    
    @objc func emailChanged(_ sender: UITextField) {
        let updatedProfile = MyProfile.init(email: emailText.text)
        extoleApp?.updateProfile(profile: updatedProfile)
    }
    
    @objc func logoutClick(_ sender: UIButton) {
        let logoutConfimation = UIAlertController(title: "Logout", message: "Confirm logout.", preferredStyle: .actionSheet)
        
        logoutConfimation.addAction(UIAlertAction(title: NSLocalizedString("Yes, Log me out", comment: "Default action"), style: .destructive, handler: { _ in
            self.extoleApp.logout()
        }))
        logoutConfimation.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: nil))
        self.present(logoutConfimation, animated: true, completion: nil)
    }
}
