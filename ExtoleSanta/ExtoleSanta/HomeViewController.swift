//Copyright © 2019 Extole. All rights reserved.

import Foundation
import UIKit
import ExtoleKit

class HomeViewController : UIViewController {
   
    var santaApp: ExtoleSanta!
    var refreshControlCompat: UIRefreshControl?
    var tableView: UITableView!
    
    var identifyViewController: IdentifyViewController!
    var profileViewController: ProfileViewController!
    var activityViewController: UIActivityViewController!
    
    let cellId = "cellId"
    
    func getIdentity() -> String {
        return "ID"
    }

    let sections: [TableSection] = [.Wishlist, .Identity, .Profile]
    
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
        self.title = "Home"
        self.view.backgroundColor = UIColor.white
        tableView = self.view.newTableView()

        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: self.safeArea()).isActive = true
        }
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)

        tableView.separatorStyle = .singleLine

        busyIndicator.frame = CGRect(x: 0, y: 0, width: 240, height: 240)
        var viewCenter = view.center
        viewCenter.y /= 2
        busyIndicator.center = viewCenter
        self.view.addSubview(busyIndicator)
        self.view.bringSubviewToFront(busyIndicator)

        self.refreshControlCompat = UIRefreshControl()
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControlCompat
        } else {
            self.tableView.addSubview(refreshControlCompat!)
        }
        refreshControlCompat?.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        santaApp.activate()
        busyIndicator.startAnimating()
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
        
        [ santaApp.shareSettings?.item1,
          santaApp.shareSettings?.item2,
          santaApp.shareSettings?.item3,
          santaApp.shareSettings?.item4].forEach { item in
            if let giftItem = item {
            wishPicker.addAction(UIAlertAction(title: NSLocalizedString(giftItem, comment: giftItem),
                                               style: .default,  handler: { _ in
                                                self.addWishToShareable(item: giftItem)
            }))
            }
        }
        
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
                                                    self.showError(title: "UpdateError", message: String(describing: error))
        })
    }

    @objc func handleShare(_ sender: UIButton) {
        guard let shareLink = santaApp.selectedShareable?.link else {
            self.showError(title: "Invalid state", message: "No Shareable")
            return
        }
        let message = santaApp.shareSettings?.shareMessage ?? "Default message"
        
        let fullMessage = "\(message) \(shareLink)"
        let shareItem = ShareItem.init(subject: "Extole Santa Wish",
                                       message: fullMessage,
                                       shortMessage: shareLink)
        let textToShare = [ shareItem  ]
        let extoleShare = ExtoleShareActivity.init(santaApp: self.santaApp, shareItem: shareItem)
        self.activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: [extoleShare])
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]
        
        // present the view controller
        activityViewController.completionWithItemsHandler =  {(activityType : UIActivity.ActivityType?, completed : Bool, returnedItems: [Any]?, activityError : Error?) in
            if let completedActivity = activityType, completed {
                switch (completedActivity) {
                case ExtoleShare: break
                default : do {
                    self.busyIndicator.startAnimating()
                    self.santaApp.signalShare(channel: completedActivity.rawValue,
                                              success : { _ in
                                                DispatchQueue.main.async {
                                                    self.busyIndicator.stopAnimating()
                                                }
                                                },
                                              error : { error in
                                                DispatchQueue.main.async {
                                                    self.busyIndicator.stopAnimating()
                                                    self.showError(title: "Share Error", message: String(describing: error))
                                                    }
                                                })
                    }
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

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectedSection = sections[section]
        return selectedSection.getIUTableSection(profile: santaApp.profile, shareable: santaApp.selectedShareable).values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let section = sections[indexPath.section]
        let value = section.getIUTableSection(profile: santaApp.profile,
                                           shareable: santaApp.selectedShareable).values[indexPath.row]
        
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let selectedSection = sections[section]
        return selectedSection.getIUTableSection(profile: santaApp.profile, shareable: santaApp.selectedShareable).title;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        let section = sections[indexPath.section]
        return section.getEditController(controller: self) != nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        if let editController = section.getEditController(controller: self) {
            self.navigationController?.pushViewController(
                editController, animated: false)
        }
    }
}

struct UITableSection {
    let title: String
    let values: [String?]
}

enum TableSection {
    case Identity
    case Profile
    case Wishlist
    
    private func wishList(shareable: MyShareable?) -> [String?] {
        var wishItems = shareable?.data ?? [:]
        if wishItems.isEmpty {
            wishItems["Add items from Extole Santa list"] = "default"
        }
        
        return wishItems.keys.map { key -> String? in
            return key
        }
    }
    
    func getIUTableSection(profile: MyProfile?, shareable: MyShareable?) -> UITableSection{
        switch self {
        case .Identity:
            return UITableSection(title: "Identity", values: [ profile?.email] )
        case .Profile:
            return UITableSection(title: "Profile", values: [
                profile?.first_name,
                profile?.last_name ])
        case .Wishlist:
            return UITableSection(title: "Wish List", values: wishList(shareable: shareable))
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
