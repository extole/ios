//
//  SessionViewController.swift
//  firstapp
//
//  Created by rtibin on 2/4/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation
import UIKit

class SessionViewController : UITableViewController {
    var extoleApp: ExtoleApp!
    
    var identifyViewController: IdentifyViewController!
    var profileViewController: ProfileViewController!
    var shareController : ShareViewController!
    
    let cellId = "cellId"
    
    struct MainSection {
        let name: String
        let controls: [()->String?]
    }
    
    func getIdentity() -> String {
        return "ID"
    }
    
    enum Section {
        case Identity
        case Profile
        case Share
        
        func getMainSection(app: ExtoleApp) -> MainSection{
            switch self {
            case .Identity:
                return MainSection(name: "Identity", controls: [{
                    return app.profile?.email}
                    ])
            case .Profile:
                return MainSection(name: "Profile", controls: [{
                        return app.profile?.first_name
                    }, {
                        return app.profile?.last_name
                    }])
            
            case .Share :
                return MainSection(name: "Share", controls: [{
                    return app.shareMessage
                }, {
                    return app.selectedShareable?.link
                }])
            }
        }
        
        func getEditController(controller: SessionViewController) -> UIViewController {
            switch self {
            case .Identity:
                return controller.identifyViewController
            case .Profile:
                return controller.profileViewController
            
            case .Share:
                return controller.shareController
            }
        }
    }
    
    let sections: [Section] = [.Identity, .Profile, .Share]
    
    init(with extoleApp: ExtoleApp) {
        self.extoleApp = extoleApp
        self.identifyViewController = IdentifyViewController.init(with : extoleApp)
        self.profileViewController = ProfileViewController.init(with : extoleApp)
        self.shareController = ShareViewController(with: extoleApp)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func nextClick(_ sender: UIButton) {
        navigationController?.pushViewController(shareController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        self.view.backgroundColor = UIColor.white
        
        extoleApp.notification.addObserver(self, selector: #selector(stateChanged),
                                           name: NSNotification.Name.state, object: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        showState(app: extoleApp)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectedSection = sections[section]
        return selectedSection.getMainSection(app: extoleApp).controls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reusableCell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if (reusableCell == nil) {
            reusableCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                               reuseIdentifier: cellId)
        }
        let cell = reusableCell!
        let section = sections[indexPath.section]
        let value = section.getMainSection(app: extoleApp).controls[indexPath.row]()
        
        if let presentValue = value {
            cell.textLabel?.text = presentValue
            cell.textLabel?.backgroundColor = .white
        } else {
            cell.textLabel?.text = "(none)"
            cell.textLabel?.backgroundColor = UIColor.lightGray
            
        }
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityLabel = "Edit"
        cell.detailTextLabel?.text = "Detail"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "\(sections[section])"
        label.backgroundColor = UIColor.gray
        return label
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    @objc private func stateChanged(_ notification: Notification) {
        guard let extoleApp = notification.object as? ExtoleApp else {
            return
        }
        showState(app: extoleApp)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let editController = section.getEditController(controller: self)
        
        self.navigationController?.pushViewController(
            editController, animated: false)
        
    }
    
    func showState(app: ExtoleApp) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            switch(app.state) {
            case .LoggedOut : do {
                let nextSession = UIBarButtonItem.init(title: "New", style: .plain, target: self, action: #selector(self.newSessionClick))
                self.navigationItem.rightBarButtonItem = nextSession
                self.navigationItem.leftBarButtonItem = nil
                }
            case .ReadyToShare : do {
                let share = UIBarButtonItem.init(barButtonSystemItem: .action, target: self
                    , action: #selector(self.doShare))
                self.navigationItem.rightBarButtonItem = share
                }
                /*
            case .Identify : do {
                self.navigationController?.pushViewController(self.identifyViewController, animated: true)
                }
            case .Identified : do {
                self.navigationController?.pushViewController(
                    self.identifyViewController.profileViewController, animated: false)
                }
            case .PopulateProfile : do {
                self.navigationController?.pushViewController(
                    self.identifyViewController.profileViewController, animated: false)
                }
            case .ReadyToShare : do {
                self.navigationController?.pushViewController(
                    self.identifyViewController.profileViewController.shareController, animated: false)
                }
    */
            default: do {
                let logout = UIBarButtonItem.init(title: "Logout", style: .plain, target: self, action: #selector(self.logoutClick))
                self.navigationItem.leftBarButtonItem = logout

                let nextSession = UIBarButtonItem.init(title: "Share", style: .plain, target: self, action: #selector(self.nextClick))
                self.navigationItem.rightBarButtonItem = nextSession
                }
            }
            
        }
    }
    
    
    @objc class ShareItem : NSObject, UIActivityItemSource {
        let message: String
        let shortMessage: String
        let subject: String
        init (subject: String, message: String, shortMessage: String) {
            self.subject = subject
            self.message = message
            self.shortMessage = shortMessage
        }
        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            return shortMessage
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            switch activityType {
            case UIActivity.ActivityType.message: return shortMessage
            default: return message
            }
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
            return subject
        }
    }
    
    @objc func doShare(_ sender: UIButton) {
        guard let shareLink = extoleApp.selectedShareable?.link else {
            showError(view: self, message: "No Shareable")
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
        self.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler =  {(activityType : UIActivity.ActivityType?, completed : Bool, returnedItems: [Any]?, activityError : Error?) in
            if let completedActivity = activityType, completed {
                switch(completedActivity) {
                case UIActivity.ActivityType.mail : do {
                    self.extoleApp.signalEmailShare()
                    }
                case UIActivity.ActivityType.message : do {
                    self.extoleApp.signalMessageShare()
                    }
                case UIActivity.ActivityType.postToFacebook : do {
                    self.extoleApp.signalFacebookShare()
                    }
                default : do {
                    self.extoleApp.signalShare(channel: completedActivity.rawValue)
                    }
                }
                
            }
        }
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
}
