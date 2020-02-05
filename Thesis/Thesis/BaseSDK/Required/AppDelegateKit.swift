//
//  AppDelegateKit.swift
//
//  Created by Angel Henderson on 9/15/17.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import Foundation

import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseAuth
import FirebaseDynamicLinks

import GoogleSignIn
import FBSDKCoreKit

import Fabric
import Crashlytics

import AEAppVersion

import MediaPlayer

import UserNotifications
import AEAppVersion
import Times

import AVFoundation
import AVKit
import WhatsNewKit

extension AppDelegate {

    
    // MARK: - App Install/Update Functions
    
    @objc func cleanInstallFunction(){
        AppStoreReviewKit.resetRunCounts()
    }
    
    @objc func equalVersionFunction(){
        print("EqualVersionFunction")
    }
    
    @objc func updateVersionFunction(){
        AppStoreReviewKit.resetRunCounts()
    }
    
    @objc func rollbackVersionFunction(){
        AppStoreReviewKit.resetRunCounts()
    }
    
    // MARK: - Background Fetch
    
    @objc func backgroundFetchFunction(){
        //trackEvent(category: "SDK", action: "BackgroundFetch", value: 1)
    }
}


extension AppDelegateKit {
    static var appDelegate = UIApplication.shared.delegate as! AppDelegate
}


@objc class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    //AVFoundation
    var avPlayer: AVPlayer?
    var avPlayerViewController = AVPlayerViewController()

    //Remote Command Components
    var NowPlayingInfoCenterTitle:String?
    var NowPlayingInfoCenterArtist:String?
    var NowPlayingInfoCenterImage:UIImage?
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        overrideConfigurations()


        // Setup AVAudioSession to indicate to the system you how intend to play audio.
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
//            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            
            try! audioSession.setCategory(.playback, mode: .default, options: [AVAudioSession.CategoryOptions.duckOthers])

        }
        catch {
            print("An error occured setting the audio session category: \(error)")
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()

        print("Original Launch Option")
        
        //Keyboard Management
        IQKeyboardManager.shared.enable = true

        //Facebook
       // ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions:launchOptions)
        
        //Analytics
        if AppCoreKit.supportGoogleAnalytics == true {googleAnalyticsSetup()}
        if AppCoreKit.supportFirebase == true {firebaseSetup()}
        if AppCoreKit.supportFabric == true {fabricSetup()}

        
        AppDelegateKit.globalSetup(application: application)

        userSetup()
        
        //Google
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        additionalSetups()

        // Checks for new app version
        switch AEAppVersion.shared.state {
        case .equal:
            equalVersionFunction()
        case .new:
            cleanInstallFunction()
        case .update(let newVersion):
            updateVersionFunction()
        case .rollback(let previousVersion):
            rollbackVersionFunction()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,object:avPlayer?.currentItem)
        NotificationCenter.default.addObserver(self,selector: #selector(foregroundNotification(notification:)),name: UIApplication.willEnterForegroundNotification,object: nil)
        
        avPlayerViewController.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.avPlayerViewController.player?.currentItem?.status == .readyToPlay {
                print("Update NowPlaying Info Center")
                self.updateNowPlayingInfoCenter()
            }
        }
        
        NSSetUncaughtExceptionHandler { exception in
            print(exception)
            print(exception.callStackSymbols)
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        //Background Video Support
        avPlayerViewController.player = nil
        

    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        //Background Video Support
        avPlayerViewController.player = avPlayer

    }
    
    func applicationDidEnterForeground(_ application: UIApplication) {

    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        connectToFcm()
        //Sets App Badge Count
        getDeliveredNotificationsCount()
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AudioKit"), object: nil)
        
        CommonKit.notificationPost(name: "AudioKit")
        //if AudioKit.ndAudioPlayer.isPaused || AudioKit.ndAudioPlayer.isStopped {AudioKit.ndAudioPlayer.pauseAudio()}
        
        //Facebook SDK - Call the 'activate' method to log an app event for use in analytics and advertising reporting.
        //AppEventsLogger.activate(application)
        AppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    
    // MARK: - UserKit
    
    func userSetup(){
        
    }
    
    func signInLogic() {
        trackUserProperty(key: "SignedIn", value: "true")
    }
    
    func signedInLogic() {
        trackUserProperty(key: "SignedIn", value: "true")
    }
    
    func logUser(){}
    
    
    func additionalSetups(){

    }
    
    // MARK: - Firebase

    func firebaseSetup(){
        FirebaseApp.configure()
        print("Firebase Configured")

        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }

        // Add observer for InstanceID token refresh callback.
        //NotificationCenter.default.addObserver(appDelegate, selector: #selector(appDelegate.tokenRefreshNotification(_:)), name: .firInstanceIDTokenRefresh, object: nil)
    }
    
    // MARK: - AV Player
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        print("DidReachEnd")
    }
    
    @objc func foregroundNotification(notification: Notification) {
        print("foregroundNotification")
    }
    
    
    // MARK: - Remote Command
    
    
    func updateNowPlayingInfoCenter(){
        print("updateNowPlayingInfoCenter")
        guard let title = NowPlayingInfoCenterTitle else {return}
        guard let artist = NowPlayingInfoCenterArtist else {return}
        guard let image = NowPlayingInfoCenterImage else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : artist,  MPMediaItemPropertyTitle : title, MPNowPlayingInfoPropertyElapsedPlaybackTime: avPlayerViewController.player?.currentTime(), MPMediaItemPropertyPlaybackDuration: avPlayerViewController.player?.currentItem?.duration, MPMediaItemPropertyArtwork: MPMediaItemArtwork.init(image: AppCoreKit.appIcon)]
            return
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : artist,  MPMediaItemPropertyTitle : title, MPNowPlayingInfoPropertyElapsedPlaybackTime: avPlayerViewController.player?.currentTime(), MPMediaItemPropertyPlaybackDuration:avPlayerViewController.player?.currentItem?.duration, MPMediaItemPropertyArtwork: MPMediaItemArtwork.init(image: image)]
    }
    
    func setupVideoRemoteCommandCenterSetup(){
        print("Setup Video RemoteCommand Center")
        //Remote Command Center - https://developer.apple.com/reference/mediaplayer/mpremotecommandcenter
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        
        remoteCommandCenter.playCommand.isEnabled = true
        remoteCommandCenter.pauseCommand.isEnabled = true
        remoteCommandCenter.togglePlayPauseCommand.isEnabled = false
        remoteCommandCenter.skipBackwardCommand.isEnabled = true
        remoteCommandCenter.skipBackwardCommand.preferredIntervals = [15]
        remoteCommandCenter.skipForwardCommand.isEnabled = true
        remoteCommandCenter.skipForwardCommand.preferredIntervals = [15]
        
        remoteCommandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.avPlayerViewController.player?.play()
            return .success
        }
        remoteCommandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.avPlayerViewController.player?.pause()
            return .success
        }
        
        remoteCommandCenter.skipBackwardCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            let playerCurrentTime = CMTimeGetSeconds((self?.avPlayer?.currentTime())!)
            var newTime = playerCurrentTime - 15
            if newTime < 0 {newTime = 0}
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            self?.avPlayerViewController.player?.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            return .success
        }
        
        remoteCommandCenter.skipForwardCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let duration  = self?.avPlayer?.currentItem?.duration else {return .commandFailed}
            let playerCurrentTime = CMTimeGetSeconds((self?.avPlayer?.currentTime())!)
            let newTime = playerCurrentTime + 15
            
            if newTime < (CMTimeGetSeconds(duration) - 15) {
                let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                self?.avPlayerViewController.player?.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            }
            return .success
            
        }
    }
    
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {

            print("Dynamic Link: \(dynamicLink)")
            
            if let path = dynamicLink.url?.path, let absoluteString = dynamicLink.url?.absoluteString {
                return deepLinkingFunction(urlString: path, absoluteString: absoluteString) ?? true
            }
            return true
        }
        
        let handled = ApplicationDelegate.shared.application(app, open: url, options: options)

        if Auth.auth().canHandle(url) {
            return true
        }
        
        return handled
        
        //return application(app, open: url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        //  return false
    }
    
    // MARK: - Handoff
    func generalActivityFunction(userActivity: NSUserActivity){
        trackEvent(category: "SDK", action: "Handoff", value: 1)
        if let info = userActivity.userInfo?["info"] as? String {
            processCoreSpotlight(uniqueIdentifier:info)
        }
    }
    
    //MARK: Core Spotlight
    func processCoreSpotlight(uniqueIdentifier: String){
        trackEvent(category: "CoreSpotlight", action: uniqueIdentifier, value: 1)
    }
    
    //MARK: Deep Linking (NSUserActivityTypeBrowsingWeb)
    func deepLinkingFunction(urlString: String, absoluteString:String) -> Bool? {
        trackEvent(category: "SDK", action: "Deeplinking", label:absoluteString, value: 1)
        return true
    }

    
    // MARK: Website Deep Linking and CoreSpotlight
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        print("Continue NSUserActivity continue userActivity processing with \(userActivity.activityType)")
        
        DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            print("Dynamic Link: \(dynamiclink)")
            if let dlink = dynamiclink {
                self.deepLinkingFunction(urlString: (dlink.url?.path)!, absoluteString: (dlink.url?.absoluteString)!)!
            }
        }
        
        //CoreSpotlight Logic
        if userActivity.activityType == "com.apple.corespotlightitem" {
            print("CoreSpotlight processing with \(userActivity.userInfo)")
            if let uniqueIdentifier = userActivity.userInfo?["kCSSearchableItemActivityIdentifier"] as? String {
                processCoreSpotlight(uniqueIdentifier:uniqueIdentifier)
            }
            return true
        }
        
        //Website Deeplink Logic
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb{
            print("Website Deeplink processing with \(userActivity.userInfo)")
            if let url = userActivity.webpageURL{
                let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                let userActivityUrl: String = (userActivity.webpageURL?.path)!
                let absoluteString: String = (userActivity.webpageURL?.absoluteString)!
                print("Deeplink url is \(userActivityUrl)")
                return deepLinkingFunction(urlString: userActivityUrl, absoluteString: absoluteString)!
            }
        }
        
        //Handoff Logic
        //Example: com.salemwebnetwork.Oneplace.general
        
        if userActivity.activityType == generalActivityKey {
            generalActivityFunction(userActivity: userActivity)
        }
        
        print("Handoff processing with \(userActivity.userInfo)")
        
        if let tabBarController = self.window!.rootViewController as? UITabBarController {
            let currentNavigationController = tabBarController.selectedViewController as! UINavigationController
            currentNavigationController.visibleViewController?.restoreUserActivityState(userActivity)
            //currentNavigationController.pushViewController(ministryDetailViewController, animated: false)
            return true
        }
        
        return true
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        print("NSUserActivity continue userActivity processing with \(userActivity.activityType)")
        
        DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            print("Dynamic Link: \(dynamiclink)")

            if let dlink = dynamiclink {
                self.deepLinkingFunction(urlString: (dlink.url?.path)!, absoluteString: (dlink.url?.absoluteString)!)!
            }
        }
        
        //CoreSpotlight Logic
        if userActivity.activityType == "com.apple.corespotlightitem" {
            print("CoreSpotlight processing with \(userActivity.userInfo)")
            if let uniqueIdentifier = userActivity.userInfo?["kCSSearchableItemActivityIdentifier"] as? String {
                processCoreSpotlight(uniqueIdentifier:uniqueIdentifier)
            }
            return true
        }
        
        //Website Deeplink Logic
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb{
            print("Website Deeplink processing with \(userActivity.userInfo)")
            if let url = userActivity.webpageURL{
                let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                let userActivityUrl: String = (userActivity.webpageURL?.path)!
                let absoluteString: String = (userActivity.webpageURL?.absoluteString)!
                print("Deeplink url is \(userActivityUrl)")
                return deepLinkingFunction(urlString: userActivityUrl, absoluteString: absoluteString)!
            }
        }
        
        //Handoff Logic
        //Example: com.salemwebnetwork.Oneplace.general
        
        if userActivity.activityType == generalActivityKey {
            generalActivityFunction(userActivity: userActivity)
        }
        
        print("Handoff processing with \(userActivity.userInfo)")
        
        if let tabBarController = self.window!.rootViewController as? UITabBarController {
            let currentNavigationController = tabBarController.selectedViewController as! UINavigationController
            currentNavigationController.visibleViewController?.restoreUserActivityState(userActivity)
            //currentNavigationController.pushViewController(ministryDetailViewController, animated: false)
            return true
        }
        
        return true
    }
    
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        print("WillContinueUserActivityWithType processing with \(userActivityType)")
        print("WillContinueUserActivity Info with \(userActivity?.userInfo)")
        
        
        //CoreSpotlight Logic
        if userActivity?.activityType == "com.apple.corespotlightitem" {
            print("CoreSpotlight processing with \(userActivity?.userInfo)")
            if let uniqueIdentifier = userActivity?.userInfo?["kCSSearchableItemActivityIdentifier"] as? String {
                processCoreSpotlight(uniqueIdentifier:uniqueIdentifier)
            }
            return true
        }
        
        //Website Deeplink Logic
        if userActivity?.activityType == NSUserActivityTypeBrowsingWeb{
            print("Website Deeplink processing with \(userActivity?.userInfo)")
            if let url = userActivity?.webpageURL{
                let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                let userActivityUrl: String = (userActivity?.webpageURL?.path)!
                let absoluteString: String = (userActivity?.webpageURL?.absoluteString)!
                print("Deeplink url is \(userActivityUrl)")
                return deepLinkingFunction(urlString: userActivityUrl, absoluteString: absoluteString)!
            }
        }
        
        //Handoff Logic
        //Example: com.salemwebnetwork.Oneplace.general
        
        if userActivity?.activityType == generalActivityKey {
            if let activity = userActivity {
                generalActivityFunction(userActivity: activity)
            }
        }
        
        print("Handoff processing with \(userActivity?.userInfo)")
        
        if let tabBarController = self.window!.rootViewController as? UITabBarController {
            if let activity = userActivity {
                let currentNavigationController = tabBarController.selectedViewController as! UINavigationController
                currentNavigationController.visibleViewController?.restoreUserActivityState(activity)
            }
            //currentNavigationController.pushViewController(ministryDetailViewController, animated: false)
            return true
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        //print("DidFailToContinueUserActivityWithType processing with \(userActivityType)")
        //print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        print("didUpdate userActivity with \(userActivity)")
        print(userActivity.userInfo)
    }
    
    
    
    //MARK: - Local and Remote Notification
    func notificationFunction(userInfo:[AnyHashable: Any]) -> Void {
    }
    
}


struct AppDelegateKit {
    
    static func globalSetup(application: UIApplication){
        
        //Cache
        if AppCoreKit.supportCaching == true {
            let cache = URLCache(memoryCapacity: AppCoreKit.cacheSize, diskCapacity: AppCoreKit.diskSize, diskPath: nil)
            URLCache.shared = cache
        }
        
        //Notification
        UNUserNotificationCenter.current().delegate = appDelegate
        
        DispatchQueue.main.async(execute: {
            //UIApplication.shared.registerForRemoteNotifications()
            requestNotificationSetup()
        })
        
        //requestNotificationSetup()
        
        //Background Fetch
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        //Versioning
        AEAppVersion.launch()

        //Google Authenication
        googleAuthSetup()
        
        //Message Center
        if AppCoreKit.supportMessageCenter == true {
            initiateMessageCenter()
        }
        
        //Cloud
        syncUserDefault()
        
        //Reachability
        ReachabilityKit.setupReachability("google.com")

        //if AppCoreKit.supportAudioPlayer == true {remoteCommandCenterSetup()}
        
        if AppCoreKit.supportBackgroundAudio == true {
            let audioSession = AVAudioSession.sharedInstance()
            try! audioSession.setCategory(.playback, mode: .default, options: [AVAudioSession.CategoryOptions.duckOthers])

            //try!audioSession.setCategory(AVAudioSession.Category.playback, with: AVAudioSession.CategoryOptions.duckOthers)
        }
        
        colorSchemeSetup()        
    }
}

// MARK: Background Mode
extension AppDelegate {
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("performFetchWithCompletionHandler")
        trackEvent(category: "SDK", action: "BackgroundFetch", value: 1)
        backgroundFetchFunction()
        completionHandler(UIBackgroundFetchResult.newData)
    }
}


// MARK: - Color Setup

func colorSchemeSetup(){
    //Theme Color
    AppDelegateKit.appDelegate.window?.tintColor = ColorKit.themeColor
}

// MARK: - Fabric

func fabricSetup(){
    Fabric.with([Crashlytics.self])
}

// MARK: - Google Auth

func googleAuthSetup(){
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
}

// MARK: - Google

func googleAnalyticsSetup(){
//    guard let gai = GAI.sharedInstance() else {
//        //assert(false, "Google Analytics not configured correctly")
//        fatalError("Google Analytics not configured correctly")
//    }
//    gai.tracker(withTrackingId: AnalyticsKit.UAToken)
//    gai.tracker(withTrackingId: AnalyticsKit.UAToken).allowIDFACollection = true
//    gai.trackUncaughtExceptions = true
}

// MARK: - Firebase

let gcmMessageIDKey = "gcm.message_id"

// MARK: Firebase Delegates

extension AppDelegate : MessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    @objc(applicationReceivedRemoteMessage:) func application(received remoteMessage: MessagingRemoteMessage) {
        print("Application Received Remote Message")
        print(remoteMessage.appData)
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if let token = Messaging.messaging().fcmToken {
            print("FCM Token: \(token)")
        } else {
            print("FCM Token: nil")
        }
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}


