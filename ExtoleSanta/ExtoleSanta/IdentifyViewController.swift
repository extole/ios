//
//  IdentifyViewController.swift
//  firstapp
//
//  Created by rtibin on 2/4/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation
import UIKit
import ExtoleKit

class IdentifyViewController: UIViewController {
    
    var extoleApp: ExtoleApp!
    
    var emailText: UITextField!
    
    init(with extoleApp: ExtoleApp) {
        self.extoleApp = extoleApp
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func done(_ sender: UIButton) {
        if let email = emailText.text {
            extoleApp.session!.identify(email: email) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        let errorAlert = UIAlertController(title: "Identify Error", message: "\(error)", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { _ in
                            //
                        }))
                        self.present(errorAlert, animated: true, completion: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Identify"
        self.view.backgroundColor = UIColor.white
        
        let emailLabel = view.newLabel(text: "Email:")
        emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            emailLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: self.safeArea()).isActive = true
            // Fallback on earlier versions
        }
        emailLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        emailLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        emailText = view.newText(placeholder: "me@email.com")
        emailText.autocapitalizationType = .none
        emailText.topAnchor.constraint(equalTo: emailLabel.topAnchor).isActive = true
        emailText.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor).isActive = true
        emailText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        emailText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        let done = UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(self.done))
        self.navigationItem.rightBarButtonItem = done
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.emailText.text = extoleApp.profile?.email ?? ""
    }
}
