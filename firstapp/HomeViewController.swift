//
//  HomeViewController.swift
//  firstapp
//
//  Created by rtibin on 2/1/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UITabBarController, UITabBarControllerDelegate {
    
    var extoleApp: ExtoleApp!
    var shareController : ShareViewController!
    var profileController: ProfileViewController!
    var historyController: HistoryViewController!
    
    init(with extoleApp: ExtoleApp) {
        self.extoleApp = extoleApp
        profileController = ProfileViewController(with: extoleApp)
        shareController = ShareViewController(with: extoleApp)
        historyController = HistoryViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.delegate = self
        
        profileController.tabBarItem =  UITabBarItem.init(tabBarSystemItem: .favorites, tag: 1)
        
        shareController.tabBarItem =  UITabBarItem.init(tabBarSystemItem: .contacts, tag: 2)
        
        historyController.tabBarItem =  UITabBarItem.init(tabBarSystemItem: .history, tag: 3)
        
        viewControllers = [profileController, shareController, historyController]
        
        navigationItem.title = "Home"
        
    }
    
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("Should select viewController: \(viewController.title) ?")
        tabBarController.selectedIndex = 1
        return true;
    }

}
