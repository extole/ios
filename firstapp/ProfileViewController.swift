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
    
    var firstNameText: UITextField!
    
    var lastNameText: UITextField!
    
    @objc func profileChanged(_ sender: UITextField) {
        let updatedProfile = MyProfile.init(first_name: firstNameText.text,
                                            last_name: lastNameText.text)
        extoleApp?.updateProfile(profile: updatedProfile)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func showState(app: ExtoleApp) {
        DispatchQueue.main.async {
            let next = UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(self.nextClick))
            self.navigationItem.rightBarButtonItem = next
            if let profile = app.profile {
                self.firstNameText.text = profile.first_name
                self.lastNameText.text = profile.last_name
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
        extoleApp.prepareShare()
        //navigationController?.pushViewController(shareController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        self.view.backgroundColor = UIColor.white
       
        let firstNameLabel = newLabel(parentView: view, text: "FirstName:")
        firstNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        firstNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showState(app: extoleApp)
    }
    
}

