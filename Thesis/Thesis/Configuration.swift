//
//  Configuration.swift
//  Alpha
//
//  Created by Angel Henderson on 6/30/18.

//

import Foundation
import SwiftyJSON
import SafariServices
import Firebase
import WhatsNewKit

let authenicationCopy = ""

func overrideConfigurations(){
    ColorKit.themeColor = #colorLiteral(red: 0.3301599622, green: 0.5676314235, blue: 0.947881639, alpha: 1)

    AnalyticsKit.UAToken = "UA-66716002-1"
    
    AppCoreKit.supportBackgroundAudio = false
    
    AppCoreKit.appName = "Thesis"
    AppCoreKit.appDescription = "Common Sense Reasoning"
    
    AppCoreKit.introDescription = "Common Sense Reasoning"
    AppCoreKit.spotlightDescription = "You can now search for your details through Spotlight."
    AppCoreKit.pushNotificationDescription = "Receive push notifications when new details are available."
    AppCoreKit.siriDescription = "You can now use Siri to find new details."
    
    AppCoreKit.bundleIdentifier = "com.angelhenderson.Thesis"
    AppCoreKit.appID = "747189907"
    AppCoreKit.appIcon = #imageLiteral(resourceName: "appicon")
    
    AppCoreKit.supportNightMode = true

    TabBarKit.tabIconSize = 16
    WhatsNewKit.Default = WhatsNew(
        // The Title
        title: "What's New",
        // The features you want to showcase
        items: [
            WhatsNew.Item(
                title: "Play Video in the background",
                subtitle: "Now you can play your favorite shows in the background",
                image: UIImage.ionicon(with: .heart, textColor: ColorKit.themeColor, size: CGSize(width: 50, height: 50))
            ),
            WhatsNew.Item(
                title: "Trending",
                subtitle: "Easy to discover trending content",
                image: UIImage.ionicon(with: .heart, textColor: ColorKit.themeColor, size: CGSize(width: 50, height: 50))
            ),
            WhatsNew.Item(
                title: "Topics",
                subtitle: "Find new content based on your favorite topics",
                image: UIImage.ionicon(with: .star, textColor: ColorKit.themeColor, size: CGSize(width: 50, height: 50))
            ),
            WhatsNew.Item(
                title: "Dark Mode",
                subtitle: "Try the new dark mode by simply shaking your device",
                image: UIImage.ionicon(with: .iosCloudyNight, textColor: ColorKit.themeColor, size: CGSize(width: 50, height: 50))
            ),
            WhatsNew.Item(
                title: "Facebook Sign-In",
                subtitle: "You can now sign in using Facebook",
                image: UIImage.ionicon(with: .socialFacebook, textColor: ColorKit.themeColor, size: CGSize(width: 50, height: 50))
            ),
            WhatsNew.Item(
                title: "Google Sign-In",
                subtitle: "You can now sign in using Google",
                image: UIImage.ionicon(with: .socialGoogle, textColor: ColorKit.themeColor, size: CGSize(width: 50, height: 50))
            ),
            WhatsNew.Item(
                title: "Bug Fixes",
                subtitle: "Bug Fixes and performance improvements",
                image: UIImage.ionicon(with: .bug, textColor: ColorKit.themeColor, size: CGSize(width: 50, height: 50))
            )
        ]
    )

}


// MARK: - AppDelegate
let appDelegate = UIApplication.shared.delegate as! ThesisAppDelegate


func userSetup(){
}


func rollbackVersionFunction(){AppStoreReviewKit.resetRunCounts()}


// MARK: - App Install/Update Functions (Optional)

func cleanInstallFunction(){
    removeAllLocalNotifications()
    removeAllDeliveredNotifications()
}
func updateVersionFunction(){
    
}

func equalVersionFunction(){
}

func updateToPreviousVersionFunction(){
    
}


// MARK: - Crashlytics (Optional)
func logUser(){}

//MARK: - Background Fetch
func backgroundFetchFunction(){
}

//MARK: - Deep Linking (NSUserActivityTypeBrowsingWeb)
func deepLinkingFunction(urlString: String, absoluteString:String) -> Bool? {
    //Modified by Angel
    return true
}

//MARK: - Local and Remote Notification
//func notificationFunction(userInfo:[AnyHashable: Any]) -> Void{
//    //Oneplace DeepLink
//    if let messageUrl = userInfo["deepLinkUrl"] {
//        trackEvent(category: "DeepLink", action: "Website_Redirect", label:messageUrl as! String, value: 1)
//        trackEvent(category: "DeepLink", action: "Notification_Received", label:"Offer", value: 1)
//        let svc = SFSafariViewController(url: NSURL(string: messageUrl as! String)! as URL)
//        appDelegate.window?.rootViewController?.present(svc, animated: true, completion: nil)
//        return
//    }
//    
//    if let seopath = userInfo["seopath"] {
//        print("Seopath Recieved: \(seopath)")
//        let seopath = seopath as! String
//        trackEvent(category: "DeepLink", action: "Notification_Received", label:seopath, value: 1)
//        return
//    }
//}

//MARK: - Core Spotlight (Optional)
func processCoreSpotlight(uniqueIdentifier: String){
    //Modified by Angel
    //processCoreSpotlightOneplace(uniqueIdentifier: uniqueIdentifier)
}

//MARK: - Handoff
let ActivityVersionKey = "\(AppCoreKit.bundleIdentifier).version.key"
let ActivityVersionValue: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

//You first need to add the activity identifiers that your app supports to the target's Info.plist. Open the target's Info.plist and add the NSUserActivityTypes key. Make this item an Array and add a single item.
let generalActivityKey = "\(AppCoreKit.bundleIdentifier).general"
let userActivityKey1 = "\(AppCoreKit.bundleIdentifier).show"
let userActivityKey2 = "\(AppCoreKit.bundleIdentifier).episode"
let userActivityKey3 = "\(AppCoreKit.bundleIdentifier).search"
let userActivityKey4 = "\(AppCoreKit.bundleIdentifier).messageCenter"
let userActivityKey5 = "\(AppCoreKit.bundleIdentifier).settings"

func generalActivityFunction(userActivity: NSUserActivity){
    if let info = userActivity.userInfo?["info"] as? String {processCoreSpotlight(uniqueIdentifier:info)}
}

func userActivityFunction1(){
}

func userActivityFunction2(){
}

func userActivityFunction3(){
}

func userActivityFunction4(){
}
func userActivityFunction5(){
}

//MARK: - Additional Signin/Signout Logic (Optional)
func signInLogic() {

}

func signedInLogic() {

    trackUserProperty(key: "SignedIn", value: "true")
}

func signOutLogic() {
    trackUserProperty(key: "SignedIn", value: "false")
}

func signedOutLogic() {
    trackUserProperty(key: "SignedIn", value: "false")
}


//MARK: - Settings Details (Required)
let appStoreText = String(format: "Please check out the Alpha app! \n\nDownload the app from the App Store:")
let appStoreUrl = ""
let termsOfUseUrl = ""
let contactUsUrl = ""

//Optional Leave Blank if empty
var additionalSettingsSectionTitle: String = ""
var additionalSettingsArray:[String] = []

func additionalSettingsRowFunction1(){}
func additionalSettingsRowFunction2(){}
func additionalSettingsRowFunction3(){}
func additionalSettingsRowFunction4(){}
func additionalSettingsRowFunction5(){}
func additionalSettingsRowFunction6(){}

//MARK: - App Logo
var appIcon = #imageLiteral(resourceName: "appicon")

//MARK: - Tab Bar Configuration
var setupTabBar: Bool = false
var unSelectedColor: UIColor = .lightGray
var tabIconSize: CGFloat = 30

