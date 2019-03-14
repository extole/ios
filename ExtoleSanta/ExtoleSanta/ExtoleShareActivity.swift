//Copyright © 2019 Extole. All rights reserved.

import Foundation
import UIKit
import ExtoleKit

let ExtoleShare = UIActivity.ActivityType.init("ExtoleShare")

class ExtoleShareActivity: UIActivity {
    let santaApp: ExtoleSanta
    let shareItem: ShareItem
    
    lazy var shareController: UIViewController = {
        return UINavigationController.init(rootViewController:  ExtoleShareViewController.init(with: self.santaApp, activity: self))
    }()
    
    init(santaApp: ExtoleSanta, shareItem: ShareItem){
        self.santaApp = santaApp
        self.shareItem = shareItem
    }
    // returns activity title
    override var activityTitle: String?{
        return "ExtoleShare"
    }
    
    //thumbnail image for the activity
    override var activityImage: UIImage?{
        return UIImage(named: "AppIcon")
    }
    
    //activiyt type
    override var activityType: UIActivity.ActivityType{
        return ExtoleShare
    }
    
    //view controller for the activity
    override var activityViewController: UIViewController?{
        return shareController
    }
    
    //here check whether this activity can perfor with given list of items
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    //prepare the data to perform with
    override func prepare(withActivityItems activityItems: [Any]) {
        
    }

}

class ExtoleShareViewController: UIViewController {
    
    var santaApp: ExtoleSanta!
    var activity: ExtoleShareActivity
    
    var emailText: UITextField!
    
    init(with santaApp: ExtoleSanta, activity: UIActivity) {
        self.santaApp = santaApp
        self.activity = activity as! ExtoleShareActivity
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func done(_ sender: UIButton) {
        if let email = emailText.text {
            let share = EmailShare(recipient_email: email, message: activity.shareItem.message)
            santaApp.shareApp.send(share: share,
                            success: { _ in
                self.activity.activityDidFinish(true)
            }, error : { error in
                self.showError(title: "Share Error", message: String(describing: error))
            })
            
        }
    }

    @objc func cancel(_ sender: UIButton) {
        self.activity.activityDidFinish(false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Santa Postbox"
        self.view.backgroundColor = UIColor.white
        
        let emailLabel = view.newLabel(text: "Email:")
        emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            emailLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: self.safeArea()).isActive = true
            // Fallback on earlier versions
        }
        emailLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        emailLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        emailText = view.newText(placeholder: "santa@extole.com")
        emailText.autocapitalizationType = .none
        emailText.topAnchor.constraint(equalTo: emailLabel.topAnchor).isActive = true
        emailText.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor).isActive = true
        emailText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        emailText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        let done = UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(self.done))
        self.navigationItem.rightBarButtonItem = done
        
        let cancel = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem = cancel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.emailText.text = santaApp?.profile?.email ?? ""
    }
}
