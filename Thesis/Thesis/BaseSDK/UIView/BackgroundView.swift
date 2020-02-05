//
//  BackgroundView.swift
//
//  Created by Angel Henderson on 9/11/17.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import UIKit
import DeckTransition
import SwifterSwift


extension BackgroundView {
    func buttonFunction(){} //Configurable Function
}


class BackgroundView: UIView {

    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var button: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.backgroundColor = .primaryBackgroundColor
        titleLabel?.textColor = .primaryTextColor
        subtitleLabel?.textColor = .primaryTextColor
        button?.backgroundColor = .secondaryBackgroundColor
        button?.setTitleColorForAllStates(ColorKit.themeColor)
    }
    
    func setup(title: String, subject: String, buttonTitle: String, image: UIImage) {
        titleLabel?.text = title
        subtitleLabel?.text = subject
        imageView?.image = image
        button?.setTitleForAllStates(buttonTitle)
        //button?.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
    }

    @objc func buttonAction(sender:UIButton!){
        buttonFunction()
    }
}
