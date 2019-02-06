//
//  Common.swift
//  firstapp
//
//  Created by rtibin on 2/4/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func newLabel(text: String) -> UILabel {
        let newLabel = UILabel()
        self.addSubview(newLabel)
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        newLabel.text = text
        return newLabel
    }
    
    func newText(placeholder: String) -> UITextField {
        let newText = UITextField()
        self.addSubview(newText)
        newText.translatesAutoresizingMaskIntoConstraints = false
        newText.placeholder = placeholder
        return newText
    }
    
    func newButton(text: String) -> UIButton {
        let newButton = UIButton()
        self.addSubview(newButton)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.setTitle(text, for: .normal)
        newButton.backgroundColor = .blue
        return newButton
    }
    
    func newTextView() -> UITextView {
        let newText = UITextView()
        self.addSubview(newText)
        newText.translatesAutoresizingMaskIntoConstraints = false
        return newText
    }
    
}

extension  UIViewController {
    func safeArea() -> CGFloat {
        let safeSpace = (self.navigationController?.navigationBar.frame.height ?? 0) +
            UIApplication.shared.statusBarFrame.height
        return safeSpace
    }
    

    func showError(message : String) {
        DispatchQueue.main.async {
            let errorAlert = UIAlertController(title: "Identify Error", message: message, preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { _ in
                //
            }))
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
}
