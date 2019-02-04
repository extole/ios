//
//  Common.swift
//  firstapp
//
//  Created by rtibin on 2/4/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation
import UIKit


func newLabel(parentView: UIView, text: String) -> UILabel {
    let newLabel = UILabel()
    parentView.addSubview(newLabel)
    newLabel.translatesAutoresizingMaskIntoConstraints = false
    newLabel.text = text
    return newLabel
}

func newText(parentView: UIView, placeholder: String) -> UITextField {
    let newText = UITextField()
    parentView.addSubview(newText)
    newText.translatesAutoresizingMaskIntoConstraints = false
    newText.placeholder = placeholder
    return newText
}

func newButton(parentView: UIView, text: String) -> UIButton {
    let newButton = UIButton()
    parentView.addSubview(newButton)
    newButton.translatesAutoresizingMaskIntoConstraints = false
    newButton.setTitle(text, for: .normal)
    newButton.backgroundColor = .blue
    return newButton
}
