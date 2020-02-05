//
//  AppCoreKit.swift

//
//  Created by Angel Henderson on 6/24/18.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import Foundation

struct AppCoreKit {
    
    static var debugMode: Bool = false

    // MARK: - Required
    static var appName = ""
    static var appDescription = ""
    static var bundleIdentifier = ""
    static var appID = ""
    static var appIcon = #imageLiteral(resourceName: "appicon")
    static var storyboardIdentifier = ""

    
    static var introDescription = ""
    static var pushNotificationDescription = ""
    static var spotlightDescription = ""
    static var siriDescription = ""
    
    // App Store Descriptions
    static var appStoreText = ""
    static var appStoreUrl = ""
    static var termsOfUseUrl = ""
    static var contactUsUrl = ""
    
    //Audio
    static var supportBackgroundAudio: Bool = true
    static var supportAudioPlayer: Bool = false

    //Caching
    static var supportCaching: Bool = true
    static var cacheSize = 500 * 1024 * 1024 //500 MB
    static var diskSize = 500 * 1024 * 1024 //500 MB

    //Analytics
    static var supportFabric: Bool = true
    static var supportGoogleAnalytics: Bool = true
    static var supportFirebase: Bool = true
    static var supportFacbook: Bool = true

    //Night Mode
    static var supportNightMode: Bool = false
    
    //Message Center
    static var supportMessageCenter = false
    
    // MARK: - Optional
    static var bannerHeight: Int = 215
    static var bannerWidth: Int = 270    
}
