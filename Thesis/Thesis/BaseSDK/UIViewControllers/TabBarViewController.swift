//
//  TabBarViewController.swift

//
//  Created by Angel Henderson on 1/31/17.
//  Copyright © 2017 Angel Henderson Holding Corporation. All rights reserved.
//

import UIKit

import IoniconsKit

struct TabBarKit {
    static var setupTabBarIcons = true
    static var unSelectedColor: UIColor = .tabColor
//    containerView?.backgroundColor = traitCollection.userInterfaceStyle == .light ? .secondaryLabel : .white

    static var tabIconSize: CGFloat = 30
    
    static var tabIconSelected1 = UIImage.ionicon(with: .close, textColor: ColorKit.themeColor, size: CGSize(width: TabBarKit.tabIconSize, height: TabBarKit.tabIconSize))
    static var tabIconSelected2 = UIImage.ionicon(with: .close, textColor: ColorKit.themeColor, size: CGSize(width: TabBarKit.tabIconSize, height: TabBarKit.tabIconSize))
    static var tabIconSelected3 = UIImage.ionicon(with: .close, textColor: ColorKit.themeColor, size: CGSize(width: TabBarKit.tabIconSize, height: TabBarKit.tabIconSize))
    static var tabIconSelected4 = UIImage.ionicon(with: .close, textColor: ColorKit.themeColor, size: CGSize(width: TabBarKit.tabIconSize, height: TabBarKit.tabIconSize))
    static var tabIconSelected5 = UIImage.ionicon(with: .close, textColor: ColorKit.themeColor, size: CGSize(width: TabBarKit.tabIconSize, height: TabBarKit.tabIconSize))
    
    static var tabIconUnselected1 = UIImage.ionicon(with: .close, textColor: TabBarKit.unSelectedColor, size: CGSize(width: TabBarKit.tabIconSize, height: TabBarKit.tabIconSize))
    static var tabIconUnselected2 = UIImage.ionicon(with: .close, textColor: TabBarKit.unSelectedColor, size: CGSize(width: TabBarKit.tabIconSize, height: TabBarKit.tabIconSize))
    static var tabIconUnselected3 = UIImage.ionicon(with: .close, textColor: TabBarKit.unSelectedColor, size: CGSize(width: TabBarKit.tabIconSize, height: TabBarKit.tabIconSize))
    static var tabIconUnselected4 = UIImage.ionicon(with: .close, textColor: TabBarKit.unSelectedColor, size: CGSize(width: TabBarKit.tabIconSize, height: TabBarKit.tabIconSize))
    static var tabIconUnselected5 = UIImage.ionicon(with: .close, textColor: TabBarKit.unSelectedColor, size: CGSize(width: TabBarKit.tabIconSize, height: TabBarKit.tabIconSize))
}

class TabBarViewController: UITabBarController {
    
    func dismissMusicMiniPlayer(){dismissBar()}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.tabBar.barTintColor = .systemGroupedBackground
        
        //Music Player Dismissal
        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissBar), name: NSNotification.Name(rawValue: "dismissBar"), object: nil)
        
        //Reachibility Monitoring
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: ReachabilityKit.reachability)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if TabBarKit.setupTabBarIcons == true {
            setupTabBar()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Music Mini Player
    @objc func dismissBar() {

    }
    
    fileprivate func setupTabBar(){
        if let count = self.tabBar.items?.count {
            let arrayOfImageNameForSelectedState: [UIImage?] = [TabBarKit.tabIconSelected1,TabBarKit.tabIconSelected2,TabBarKit.tabIconSelected3,TabBarKit.tabIconSelected4,TabBarKit.tabIconSelected5]
            let arrayOfImageNameForUnselectedState: [UIImage?] = [TabBarKit.tabIconUnselected1, TabBarKit.tabIconUnselected2,TabBarKit.tabIconUnselected3, TabBarKit.tabIconUnselected4,TabBarKit.tabIconUnselected5]
            for i in 0...(count-1) {
                let imageNameForSelectedState   = arrayOfImageNameForSelectedState[i]
                let imageNameForUnselectedState = arrayOfImageNameForUnselectedState[i]
                self.tabBar.items?[i].selectedImage = imageNameForSelectedState?.withRenderingMode(.alwaysOriginal)
                self.tabBar.items?[i].image = imageNameForUnselectedState?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    // MARK: - Reachability
    @objc func reachabilityChanged(_ notification: Notification) {
        if ReachabilityKit.reachability?.isReachable == false {}
        else {}
    }
}
