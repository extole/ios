//Copyright © 2019 Extole. All rights reserved.

import UIKit
import ExtoleKit

class ProfileViewController: UIViewController {

    var extoleApp: ExtoleSanta!
    
    init(with extoleApp: ExtoleSanta) {
        self.extoleApp = extoleApp
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var firstNameText: UITextField!
    
    var lastNameText: UITextField!
    
    @objc func doneClick(_ sender: UITextField) {
        let updatedProfile = MyProfile.init(first_name: firstNameText.text,
                                            last_name: lastNameText.text)
        extoleApp?.session?.updateProfile(profile: updatedProfile, success: {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }, error:  { error in
            DispatchQueue.main.async {
                self.showError(message: "\(error)")
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        self.view.backgroundColor = UIColor.white
       
        let firstNameLabel = view.newLabel(text: "FirstName:")
        firstNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            firstNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            firstNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: self.safeArea()).isActive = true
            // Fallback on earlier versions
        }
        firstNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        firstNameLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true

        firstNameText =  view.newText(placeholder: "Joe")
        firstNameText.topAnchor.constraint(equalTo: firstNameLabel.topAnchor).isActive = true
        firstNameText.leadingAnchor.constraint(equalTo: firstNameLabel.trailingAnchor).isActive = true
        firstNameText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        firstNameText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        //
        let lastNameLabel = view.newLabel(text: "LastName:")
        lastNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lastNameLabel.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor).isActive = true
        lastNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        lastNameLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        lastNameText = view.newText(placeholder: "Doe")
        lastNameText.topAnchor.constraint(equalTo: lastNameLabel.topAnchor).isActive = true
        lastNameText.leadingAnchor.constraint(equalTo: lastNameLabel.trailingAnchor).isActive = true
        lastNameText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        lastNameText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        let next = UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(self.doneClick))
        self.navigationItem.rightBarButtonItem = next
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.firstNameText.text = extoleApp.profileLoader?.profile?.first_name ?? ""
        self.lastNameText.text = extoleApp.profileLoader?.profile?.last_name ?? ""
    }
    
}

