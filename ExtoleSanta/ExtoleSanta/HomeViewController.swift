//Copyright © 2019 Extole. All rights reserved.

import Foundation
import UIKit
import ExtoleKit

class HomeViewController : UITableViewController {
   
    var santaApp: ExtoleSanta!
    var refreshControlCompat: UIRefreshControl?
    
    var identifyViewController: IdentifyViewController!
    var profileViewController: ProfileViewController!
    
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
        case Wishlist

        func wishList(shareable: MyShareable?) -> [() -> String?] {
            let wishItems = shareable?.data ?? [:]
            return wishItems.keys.map { key -> (() -> String?) in
                return {
                    key
                }
            }
        }
        
        func getMainSection(profile: MyProfile?, shareable: MyShareable?) -> MainSection{
            switch self {
            case .Identity:
                return MainSection(name: "Identity", controls: [{
                    return profile?.email}
                    ])
            case .Profile:
                return MainSection(name: "Profile", controls: [{
                        return profile?.first_name
                    }, {
                        return profile?.last_name
                    }])
            case .Wishlist:
                return MainSection(name: "Wish List", controls: wishList(shareable: shareable))
            }
        }
        
        func getEditController(controller: HomeViewController) -> UIViewController? {
            switch self {
            case .Identity:
                return controller.identifyViewController
            case .Profile:
                return controller.profileViewController
            default:
                return nil
            }
        }
    }
    
    let sections: [Section] = [.Identity, .Profile, .Wishlist]
    
    let busyIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.santaApp = ExtoleSanta(delegate: self)
        self.identifyViewController = IdentifyViewController.init(with : santaApp)
        self.profileViewController = ProfileViewController.init(with : santaApp)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        santaApp.activate()
        self.title = "Home"
        self.view.backgroundColor = UIColor.white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        self.refreshControlCompat = UIRefreshControl()
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControlCompat
        } else {
            self.tableView.addSubview(refreshControlCompat!)
        }
        refreshControlCompat?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        tableView.separatorStyle = .singleLine
        
        busyIndicator.frame = CGRect(x: 0, y: 0, width: 240, height: 240)
        busyIndicator.center = view.center
        self.view.addSubview(busyIndicator)
        self.view.bringSubviewToFront(busyIndicator)
        
        showState()
    }

    override func viewWillAppear(_ animated: Bool) {
       showState()
    }
    
    @objc private func refreshData(_ sender: Any) {
        santaApp.reload() {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControlCompat?.endRefreshing()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectedSection = sections[section]
        return selectedSection.getMainSection(profile: santaApp.profile, shareable: santaApp.selectedShareable).controls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let section = sections[indexPath.section]
        let value = section.getMainSection(profile: santaApp.profile,
                                           shareable: santaApp.selectedShareable).controls[indexPath.row]()
        
        if let presentValue = value {
            cell.textLabel?.text = presentValue
            cell.textLabel?.isEnabled = true
        } else {
            cell.textLabel?.text = "(none)"
            cell.textLabel?.isEnabled = false
            
        }
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let selectedSection = sections[section]
        return selectedSection.getMainSection(profile: santaApp.profile, shareable: santaApp.selectedShareable).name;
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        if let editController = section.getEditController(controller: self) {
            self.navigationController?.pushViewController(
                editController, animated: false)
        }
        
    }
    
    func showState() {
        self.tableView.reloadData()
        if let _ = self.santaApp.session {
            self.navigationItem.title = "Extole Santa"
            let reset = UIBarButtonItem.init(title: "Reset", style: .plain, target: self, action: #selector(self.resetClick))
            self.navigationItem.leftBarButtonItem = reset

            let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self,
                                                  action: #selector(self.addWish))
            let shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(self.handleShare))
            
            navigationItem.rightBarButtonItems = [shareButton, addButton]
        } else {
            self.navigationItem.title = "Extole Santa - Loading"
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc func resetClick(_ sender: UIButton) {
        let logoutConfimation = UIAlertController(title: "Reset confirmation", message: "Resetting removes your profile and wishlist from device", preferredStyle: .actionSheet)
        
        logoutConfimation.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Go ahead"), style: .destructive, handler: { _ in
            self.santaApp.reset()
        }))
        logoutConfimation.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Hold on"), style: .cancel, handler: nil))
        self.present(logoutConfimation, animated: true, completion: nil)
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
    
    func addWishToShareable(item: String) {
        var wishItems = santaApp.selectedShareable?.data ?? [:]
        wishItems[item] = "please santa"
        let updateShareable = UpdateShareable.init(data: wishItems)
        let shareableCode = self.santaApp.selectedShareable?.code
        self.santaApp.session?.updateShareable(code: shareableCode!,
                                               shareable: updateShareable,
                                               success: {
                                                self.refreshData(self)
                                                } , error : { error in
            self.showError(message: "Update Error \(String(describing: error))")
        })
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func handleShare(_ sender: UIButton) {
        guard let shareLink = santaApp.selectedShareable?.link else {
            self.showError(message: "No Shareable")
            return
        }
        let message = santaApp.shareSettings?.shareMessage ?? "Default message"
        
        let fullMessage = "\(message) \(shareLink)"
        let shareItem = ShareItem.init(subject: "Extole Santa Wish",
                                       message: fullMessage,
                                       shortMessage: shareLink)
        let textToShare = [ shareItem  ]
        let extoleShare = ExtoleShareActivity.init(santaApp: self.santaApp, shareItem: shareItem)
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: [extoleShare])
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]
        
        // present the view controller
        activityViewController.completionWithItemsHandler =  {(activityType : UIActivity.ActivityType?, completed : Bool, returnedItems: [Any]?, activityError : Error?) in
            if let completedActivity = activityType, completed {
                switch (completedActivity) {
                case ExtoleShare: break
                default : self.santaApp.signalShare(channel: completedActivity.rawValue, success : { _ in }, error : { _ in })
                }
                
            }
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension HomeViewController : ExtoleSantaDelegate {
    func santaIsBusy() {
        busyIndicator.startAnimating()
        self.showState()
    }

    func santaIsReady() {
        busyIndicator.stopAnimating()
        self.showState()
    }
}
