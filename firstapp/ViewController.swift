//
//  ViewController.swift
//  firstapp
//
//  Created by rtibin on 1/11/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var accessTokenLabel: UILabel!
    
    let program = Program.init(baseUrl: "https://roman-tibin-test.extole.com")
    
    func setLabelText(text: String) {
        DispatchQueue.main.async {
            self.accessTokenLabel.text = text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dispatchQueue = DispatchQueue(label : "Extole", qos:.background)
        dispatchQueue.async {
            self.setLabelText(text: "Fetching access Token...")
            let accessToken = self.program.getToken().await(timeout: DispatchTime.now() + .seconds(10))
            if let accessToken = accessToken {
                self.setLabelText(text: "Token: \(accessToken.access_token)")
            } else {
                self.setLabelText(text: "No Token")
            }
        }
        
    }


}

