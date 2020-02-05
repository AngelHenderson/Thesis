//
//  MusicTabBarController.swift
//  Crosswalk
//
//  Created by Angel Henderson on 5/27/19.
//  Copyright © 2019 Salem Web Network. All rights reserved.
//

import UIKit

class MusicTabBarController: TabBarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    // MARK: - Music Mini Player
    override func dismissBar() {
        if let tabBarController = AppDelegateKit.appDelegate.window!.rootViewController as? UITabBarController {
            tabBarController.closePopup(animated: true, completion: nil)
        }
    }
    
}
