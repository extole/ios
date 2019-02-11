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
    
    var wishItems : [String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let selectedItem = wishItems[indexPath.row]
        cell.textLabel?.text = selectedItem
        cell.textLabel?.isEnabled = true

        return cell
    }
    
    var messageText: UITextView!
    var wishList: UITableView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Share Link"
        self.view.backgroundColor = UIColor.white
        let share = UIBarButtonItem.init(barButtonSystemItem: .action, target: self
            , action: #selector(self.doShare))
        self.navigationItem.rightBarButtonItem = share
        
        let messageLabel = view.newLabel(text: "Message:")
        messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            messageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        messageLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        messageLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        messageText = view.newTextView()
        messageText.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        messageText.topAnchor.constraint(equalTo: messageLabel.bottomAnchor).isActive = true
        messageText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        messageText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true
        messageText.text = "Dear Santa, I would like"
        
        wishList = view.newTableView()
        wishList.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        wishList.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        wishList.topAnchor.constraint(equalTo: messageText.bottomAnchor).isActive = true
        wishList.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        wishList.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        wishList.dataSource = self
        wishList.delegate = self
        //wishList.setEditing(true, animated: true)

        let toolbar = view.newToolbar()
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.topAnchor.constraint(equalTo: wishList.bottomAnchor).isActive = true
        toolbar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        toolbar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        let addItem = UIBarButtonItem.init(title: "Add Item", style: .plain, target: self, action: #selector(self.addItem))
        toolbar.setItems([addItem], animated: false)
        view.addSubview(toolbar)
        
    }
    
    @objc func addItem(_ sender: UIButton) {
        let wishPicker = UIAlertController(title: "Today Santa has", message: "Pick your wish", preferredStyle: .actionSheet)
        
        wishPicker.addAction(UIAlertAction(title: NSLocalizedString("Playstation", comment: "Great Education tool"), style: .default,  handler: { _ in
            self.wishItems.append("Playstation")
            
            //self.extoleApp.updateShareable()
            self.wishList.reloadData()
        }))
        wishPicker.addAction(UIAlertAction(title: NSLocalizedString("I am good", comment: "Dont add any wishes"), style: .cancel, handler: nil))
        self.present(wishPicker, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @objc func doShare(_ sender: UIButton) {
        guard let shareLink = extoleApp.selectedShareable?.link else {
            self.showError(message: "No Shareable")
            return
        }
        guard let message = extoleApp.shareMessage else {
            return
        }
        let shareItem = ShareItem.init(subject: "Check this out",
                                       message: message,
                                       shortMessage: shareLink)
        let textToShare = [ shareItem  ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]
        
        // present the view controller
        activityViewController.completionWithItemsHandler =  {(activityType : UIActivity.ActivityType?, completed : Bool, returnedItems: [Any]?, activityError : Error?) in
            if let completedActivity = activityType, completed {
                self.extoleApp.signalShare(channel: completedActivity.rawValue)
            }
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
}
