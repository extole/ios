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
        if let email = emailText.text {
            extoleApp.identify(email: email) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        let errorAlert = UIAlertController(title: "Identify Error", message: "\(error)", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { _ in
                            //
                        }))
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            extoleApp.populateProfile()
        }
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showState(app: extoleApp)
    }
    
    func showState(app: ExtoleApp) {
        DispatchQueue.main.async {
            let next = UIBarButtonItem.init(title: "Profile", style: .plain, target: self, action: #selector(self.nextClick))
            self.navigationItem.rightBarButtonItem = next
            
            if let profile = app.profile, !(app.profile?.email?.isEmpty ?? true) {
                self.emailText.text = profile.email
                
            }
        }
    }
}
