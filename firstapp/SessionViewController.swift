//
//  SessionViewController.swift
//  firstapp
//
//  Created by rtibin on 2/4/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation
import UIKit

class SessionViewController : UIViewController {
    var extoleApp: ExtoleApp!
    
    var identifyViewController: IdentifyViewController!
    
    init(with extoleApp: ExtoleApp) {
        self.extoleApp = extoleApp
        self.identifyViewController = IdentifyViewController.init(with : extoleApp)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func nextClick(_ sender: UIButton) {
        navigationController?.pushViewController(identifyViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Session"
        self.view.backgroundColor = UIColor.white
        
        extoleApp.notification.addObserver(self, selector: #selector(stateChanged),
                                           name: NSNotification.Name.state, object: nil)
        
        showState(app: extoleApp)
    }
    
    @objc private func stateChanged(_ notification: Notification) {
        guard let extoleApp = notification.object as? ExtoleApp else {
            return
        }
        showState(app: extoleApp)
    }
    
    func showState(app: ExtoleApp) {
        DispatchQueue.main.async {
            switch(app.state) {
            case .LoggedOut : do {
                let nextSession = UIBarButtonItem.init(title: "New", style: .plain, target: self, action: #selector(self.newSessionClick))
                self.navigationItem.rightBarButtonItem = nextSession
                self.navigationItem.leftBarButtonItem = nil
                }
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
            default: do {
                let logout = UIBarButtonItem.init(title: "Logout", style: .plain, target: self, action: #selector(self.logoutClick))
                self.navigationItem.leftBarButtonItem = logout

                let nextSession = UIBarButtonItem.init(title: "Identity", style: .plain, target: self, action: #selector(self.nextClick))
                self.navigationItem.rightBarButtonItem = nextSession
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
