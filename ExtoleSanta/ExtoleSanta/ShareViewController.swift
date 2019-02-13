//
//  ShareViewController.swift
//  firstapp
//
//  Created by rtibin on 1/25/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

import UIKit
import ExtoleKit

class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellId = "cellId"
    
    var wishItems : [String: String] = [:]
    
    var extoleShare: ExtoleShareActivity!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishItems.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let selectedIndex = wishItems.index(wishItems.startIndex, offsetBy: indexPath.row)
        let selectedValue = wishItems[selectedIndex]
        cell.textLabel?.text = selectedValue.key
        cell.textLabel?.isEnabled = true

        return cell
    }
    
    var messageText: UILabel!
    var wishList: UITableView!
    
    var addButton : UIBarButtonItem!
    var shareButton : UIBarButtonItem!
    var toolbar: UIToolbar!
    
    var extoleApp: ExtoleApp!
    
    init(with extoleApp: ExtoleApp) {
        self.extoleApp = extoleApp
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doneClick(_ sender: UITextField) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.wishItems = extoleApp.selectedShareable?.data ?? [:]
        wishList.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Wish List"
        self.view.backgroundColor = UIColor.white
        self.addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self,
            action: #selector(self.addWish))
        //self.navigationItem.rightBarButtonItem = addButton
        
        self.shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(self.handleShare))
        
        navigationItem.rightBarButtonItems = [shareButton, addButton]
        
        let message = extoleApp.shareMessage ?? "Dear Santa, check my wishlist at"
        messageText = view.newLabel(text: message)
        messageText.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            messageText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            messageText.topAnchor.constraint(equalTo: view.topAnchor, constant: self.safeArea()).isActive = true
        }
        
        messageText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        messageText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        wishList = view.newTableView()
        wishList.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        wishList.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        wishList.topAnchor.constraint(equalTo: messageText.bottomAnchor).isActive = true
        wishList.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        wishList.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7).isActive = true
        wishList.dataSource = self
        wishList.delegate = self
        
        
        //toolbar.setItems([shareButton], animated: false)
        
        
    }
    
    func addWishToShareable(item: String) {
        self.wishItems[item] = ""
        let updateShareable = UpdateShareable.init(data: self.wishItems)
        let shareableCode = self.extoleApp.selectedShareable?.code
        self.extoleApp.session?.updateShareable(code: shareableCode!, shareable: updateShareable) { error in
            if let error = error {
                self.showError(message: "Update Error \(error)")
            }
        }
        self.wishList.reloadData()
        
    }
    
    @objc func addWish(_ sender: UIButton) {
        let wishPicker = UIAlertController(title: "Pick your wish", message: "Santa has following items", preferredStyle: .actionSheet)
        wishPicker.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        wishPicker.addAction(UIAlertAction(title: NSLocalizedString("Playstation", comment: "Great Education tool"), style: .default,  handler: { _ in
            self.addWishToShareable(item: "Playstation")
        }))
        
        wishPicker.addAction(UIAlertAction(title: NSLocalizedString("XBox", comment: "Great Education tool"), style: .default,  handler: { _ in
            self.addWishToShareable(item: "XBox")
        }))
        wishPicker.addAction(UIAlertAction(title: NSLocalizedString("I am good", comment: "Dont add any wishes"), style: .cancel, handler: nil))
        self.present(wishPicker, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @objc func handleShare(_ sender: UIButton) {
        guard let shareLink = extoleApp.selectedShareable?.link else {
            self.showError(message: "No Shareable")
            return
        }
        let fullMessage = "\(messageText.text!) \(shareLink)"
        let shareItem = ShareItem.init(subject: "Extole Santa Wish",
                                       message: fullMessage,
                                       shortMessage: shareLink)
        let textToShare = [ shareItem  ]
        self.extoleShare = ExtoleShareActivity.init(extoleApp: self.extoleApp)
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: [self.extoleShare])
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]
        
        // present the view controller
        activityViewController.completionWithItemsHandler =  {(activityType : UIActivity.ActivityType?, completed : Bool, returnedItems: [Any]?, activityError : Error?) in
            if let completedActivity = activityType, completed {
                switch (completedActivity) {
                    case ExtoleShare: break
                    default : self.extoleApp.signalShare(channel: completedActivity.rawValue)
                }
                
            }
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
}
