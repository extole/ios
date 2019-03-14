//Copyright © 2019 Extole. All rights reserved.

import Foundation
import UIKit
import ExtoleKit

class IdentifyViewController: UIViewController {
    
    var santaApp: ExtoleSanta!
    
    var emailText: UITextField!
    
    init(with santaApp: ExtoleSanta) {
        self.santaApp = santaApp
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func done(_ sender: UIButton) {
        if let email = emailText.text {
            let identify = MyProfile(email: email)
            santaApp.session?.updateProfile(profile: identify, success: {
                self.santaApp.shareApp.reload {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }, error: { error in
                DispatchQueue.main.async {
                    let errorAlert = UIAlertController(title: "Identify Error", message: "\(error)", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { _ in
                            //
                    }))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            })
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
        self.emailText.text = santaApp.profile?.email ?? ""
    }
}
