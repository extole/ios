//Copyright © 2019 Extole. All rights reserved.

import Foundation
import UIKit
import ExtoleKit

let SHARE_MESSAGE_KEY = "app.shareMessage"


class HomeViewController : UITableViewController, ExtoleShareAppDelegate {
    func load() {
        DispatchQueue.main.async {
            self.refreshControlCompat?.beginRefreshing()
            self.showState()
        }
    }

    func ready() {
        DispatchQueue.main.async {
            self.refreshControlCompat?.endRefreshing()
            self.showState()
        }
    }

    var shareApp: ExtoleShareApp!
    var refreshControlCompat: UIRefreshControl?
    
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

        func getMainSection(profile: MyProfile?) -> MainSection{
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
            }
        }
        
        func getEditController(controller: HomeViewController) -> UIViewController {
            switch self {
            case .Identity:
                return controller.identifyViewController
            case .Profile:
                return controller.profileViewController
            }
        }
    }
    
    let sections: [Section] = [.Identity, .Profile]
    
    init(with shareApp: ExtoleShareApp) {
        self.shareApp = shareApp
        self.identifyViewController = IdentifyViewController.init(with : shareApp)
        self.profileViewController = ProfileViewController.init(with : shareApp)
        self.shareController = ShareViewController(with: shareApp)
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        self.refreshControlCompat = UIRefreshControl()
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControlCompat
        } else {
            self.tableView.addSubview(refreshControlCompat!)
        }
        refreshControlCompat?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        showState()
        tableView.separatorStyle = .singleLine
    }
    
    @objc private func refreshData(_ sender: Any) {
        shareApp.reload() {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControlCompat?.endRefreshing()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectedSection = sections[section]
        return selectedSection.getMainSection(profile: shareApp.profileLoader.profile).controls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let section = sections[indexPath.section]
        let value = section.getMainSection(profile: shareApp.profileLoader.profile).controls[indexPath.row]()
        
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
        return selectedSection.getMainSection(profile: shareApp.profileLoader.profile).name;
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let editController = section.getEditController(controller: self)
        
        self.navigationController?.pushViewController(
            editController, animated: false)
        
    }
    
    func showState() {
        DispatchQueue.main.async {
            self.navigationItem.title = "Home"
            self.tableView.reloadData()
            if let _ = self.shareApp.profileLoader.profile {
                
                let logout = UIBarButtonItem.init(title: "Logout", style: .plain, target: self, action: #selector(self.logoutClick))
                self.navigationItem.leftBarButtonItem = logout
                
                let wishButton = UIBarButtonItem.init(title: "To Wish List", style: .plain, target: self, action:
                    #selector(self.toWishList))
                
                self.navigationItem.rightBarButtonItem = wishButton
            } else {
                self.navigationItem.rightBarButtonItem = nil
                self.navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
    @objc func anonymousClick(_ sender: UIButton) {
        shareApp.session?.updateProfile(profile: MyProfile.init(),
                                         success: {
                                            
        }, error : { error in
            self.showError(message: "\(error)")
        })
    }


    @objc func toWishList(_ sender: UIButton) {
        navigationController?.pushViewController(shareController, animated: true)
    }
    
    @objc func logoutClick(_ sender: UIButton) {
        let logoutConfimation = UIAlertController(title: "Logout", message: "Confirm logout.", preferredStyle: .actionSheet)
        
        logoutConfimation.addAction(UIAlertAction(title: NSLocalizedString("Yes, Log me out", comment: "Default action"), style: .destructive, handler: { _ in
            self.shareApp.reset()
        }))
        logoutConfimation.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: nil))
        self.present(logoutConfimation, animated: true, completion: nil)
    }
}
