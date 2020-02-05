//
//  NavigationView.swift
//
//  Created by Angel Henderson on 9/10/17.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import UIKit

import DeckTransition
import SwifterSwift

import Closures

extension NavigationView {
    func setup(title: String, subject: String, image: UIImage){headerSetup(title: title, subject: subject, image: image)}
    func back(){backSetup()}
}

class NavigationView: UIView {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subjectLabel: UILabel?
    @IBOutlet weak var settingsButton: UIButton?

    @IBOutlet weak var subtitleButton: UIButton?
    @IBOutlet weak var backImageView: UIImageView?
    @IBOutlet weak var logoImageView:UIImageView?
    @IBOutlet weak var imageView:UIImageView?
    @IBOutlet weak var profileImageView: UIImageView?

    @IBOutlet weak var thinlineView: UIView?

    @IBOutlet weak var searchButton: UIButton?
    @IBOutlet weak var cancelButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupNightMode), name: NSNotification.Name(rawValue: "NightNightThemeChangeNotification"), object: nil)


        setupNightMode()
        
        cancelButton?.onTap {
            self.parentViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func setupNightMode() {
        //Night Mode Configuration
        self.backgroundColor = .primaryBackgroundColor
        subjectLabel?.textColor = .primaryTextColor
        thinlineView?.backgroundColor = .systemGroupedBackground

        //Image Configuration
        //appStoreImageView?.tintColor = tempColor
        //searchButton?.setImageForAllStates(UIImage.ionicon(with: .iosSearch, textColor:tempColor!, size: CGSize(width: 15, height: 15)))
        settingsButton?.setImageForAllStates(UIImage.ionicon(with: .iosGear, textColor:.primaryTextColor, size: CGSize(width: 25, height: 25)))
        //cancelButton?.setImageForAllStates(UIImage.ionicon(with: .iosClose, textColor:tempColor!, size: CGSize(width: 25, height: 25)))
        
        cancelButton?.imageView?.image = #imageLiteral(resourceName: "Close")
        cancelButton?.imageView?.image = cancelButton?.imageView?.image!.withRenderingMode(.alwaysTemplate)
        cancelButton?.imageView?.tintColor = .primaryTextColor
    
        cancelButton?.setImage(UIImage.ionicon(with: .close, textColor: .label, size: CGSize(width: 24, height: 24)), for: .normal)
    }


    func headerSetup(title: String, subject: String, image: UIImage) {
        setupNightMode()
        titleLabel?.text = title
        subjectLabel?.text = subject
        imageView?.image = image
        logoImageView?.image = AppCoreKit.appIcon
    }
    
    func backSetup() {
        setupNightMode()
        let icon = UIImage.ionicon(with: .chevronLeft, textColor:ColorKit.themeColor, size: CGSize(width: 25, height: 25))
        backImageView?.image = icon
        logoImageView?.image = icon
        titleLabel?.textColor = ColorKit.themeColor
        subtitleButton?.addTarget(self, action: #selector(dismissView(sender:)), for: .touchUpInside)
    }
    
    func cancelSetup() {
        setupNightMode()
    }

    @objc func dismissView(sender:UIButton!){
        if let navigation = parentViewController?.navigationController {
            navigation.popViewController()
        }
    }
    
    @objc func dismissNavigationView(sender:UIButton!){
        parentViewController?.dismiss(animated: true, completion: nil)
    }

}

