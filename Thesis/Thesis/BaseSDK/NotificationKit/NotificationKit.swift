//
//  NotificationKit.swift
//
//  Created by Angel Henderson on 9/15/17.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import Foundation
import SafariServices
import SwifterSwift

import UserNotifications

import Firebase
import FirebaseMessaging
import FirebaseCore
import FirebaseAuth

//import FirebaseUI

@available(iOS 10.0, *)
struct NotificationKit {
    
}



let notificationKey = "\(AppCoreKit.bundleIdentifier).notificationKey"

let APNSTokenReceivedNotification: Notification.Name
    = Notification.Name(rawValue: "APNSTokenReceivedNotification")
let UserNotificationsChangedNotification: Notification.Name
    = Notification.Name(rawValue: "UserNotificationsChangedNotification")

func isRegisteredForRemoteNotifications() -> Bool{
    if UIApplication.shared.isRegisteredForRemoteNotifications == true {
        return true
    }
    else {
        turnOffNotification()
        return false
    }
}

func turnOffNotification(){
    setUserDefault(bool: false, key: notificationKey)
    trackUserProperty(key: "false", value: "recieving_notifications")
}

func turnOnNotification(){
    setUserDefault(bool: true, key: notificationKey)
    trackUserProperty(key: "true", value: "recieving_notifications")
}

func requestNotificationSetup(){
    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    
    Messaging.messaging().delegate = AppDelegateKit.appDelegate
    Messaging.messaging().shouldEstablishDirectChannel = true
    
    
    if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = AppDelegateKit.appDelegate
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound],completionHandler: {granted, _ in
            if granted {
                print("requestAuthorization: Notification permission granted")
                turnOnNotification()
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
            else {
                //Handle user denying permissions..
                //turnOffNotification()
            }
        })

        UIApplication.shared.registerForRemoteNotifications()
    }
    else {
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    UIApplication.shared.registerForRemoteNotifications()
}

// MARK: - iOS10 Message Handling

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    //If your app is in the foreground when a notification arrives, the notification center calls this method to deliver the notification directly to your app. If you implement this method, you can take whatever actions are necessary to process the notification and update your app. When you finish, execute the completionHandler block and specify how you want the system to alert the user, if at all.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
        trackEvent(category: "SDK", action: "NotificationWillPresent", value: 1)

        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)

        //handleNotification(userInfo: userInfo)
        
        // Change this to your preferred presentation option
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    //Use this method to perform the tasks associated with your app’s custom actions. When the user responds to a notification, the system calls this method with the results. You use this method to perform the task associated with that action, if at all. At the end of your implementation, you must call the completionHandler block to let the system know that you are done processing the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        trackEvent(category: "SDK", action: "NotificationDidReceive", value: 1)

        let userInfo = response.notification.request.content.userInfo
        handleNotification(userInfo: userInfo)
        
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler()
            return
        }
        

        completionHandler()
    }
}


extension AppDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        trackEvent(category: "SDK", action: "NotificationDidReceive", value: 1)

        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    // MARK: - Receive Remote Notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        trackEvent(category: "SDK", action: "NotificationDidReceive", value: 1)

        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        if let notificationURL2 = userInfo[AnyHashable("url")] {
            print("Background Notification URL: \(notificationURL2)")
        }

        handleNotification(userInfo: userInfo)
        
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(UIBackgroundFetchResult.noData)
            return
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
        
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
        trackEvent(category: "SDK", action: "NotificationDidFail", value: 1)

    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("Device Token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
        
//        //print("APNs token retrieved: \(deviceToken)")
//        // With swizzling disabled you must set the APNs token here.
//        //InstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
//
//        //Auth.auth().setAPNSToken(deviceToken, type:AuthAPNSTokenType.sandbox)//.sandbox for development
//        Auth.auth().setAPNSToken(deviceToken, type: <#AuthAPNSTokenType#>)//.sandbox for development
//
//        print("APNS Token: \(deviceToken)")
//        NotificationCenter.default.post(name: APNSTokenReceivedNotification, object: nil)
//        if #available(iOS 8.0, *) {
//        } else {
//            // On iOS 7, receiving a device token also means our user notifications were granted, so fire
//            // the notification to update our user notifications UI
//            NotificationCenter.default.post(name: UserNotificationsChangedNotification, object: nil)
//        }
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UNNotificationSettings) {
        application.registerForRemoteNotifications()
        turnOnNotification()
        NotificationCenter.default.post(name: UserNotificationsChangedNotification, object: nil)

    }

}


// MARK: - Notifications Functions

@available(iOS 10.0, *)

func createLocalNotification(title:String, body:String, type:String, date:Date, userinfo: [AnyHashable: Any]){
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    content.badge = 1
    content.userInfo = userinfo
    //content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
    
    //Date Configuration
    let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    print("Trigger Date is \(triggerDate)")
    
    let identifier = createLocalNotificationIdentifier(date: date, type: type)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
        print("Added Local Notification Identifier: \(identifier)")
        trackEvent(category: "SDK", action: "Notification_Created", value: 1)
        if let error = error {print("Local Notification Error: \(error)")}
    })
}

func createLocalNotification(title:String, body:String, type:String, hour: Int, userinfo: [AnyHashable: Any]){
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    content.badge = 1
    content.userInfo = userinfo
    //content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
    
    //Date Configuration
    var newDate = Date()
    if newDate.hour >= hour {newDate = newDate.tomorrow}
    newDate.hour = hour
    newDate.minute = 0
    newDate.second = 0
    let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: newDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    print("Trigger Date is \(triggerDate)")
    let identifier = createLocalNotificationIdentifier(date: newDate, type: type)
    print("Local Notification Identifier: \(identifier)")
    
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
        print("Added Local Notification Identifier: \(identifier)")
        trackEvent(category: "SDK", action: "Notification_Created", value: 1)
        if let error = error {
            print("Local Notification Error: \(error)")
        }
    })
}

func createLocalNotificationAt9AM(title:String, body:String, type:String, hour: Int, userinfo: [AnyHashable: Any]){
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    content.badge = 1
    content.userInfo = userinfo
    //content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
    
    //Date Configuration
    var newDate = Date()
    if newDate.hour >= hour {newDate = newDate.tomorrow}
    newDate.hour = hour
    newDate.minute = 0
    newDate.second = 0
    let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: newDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    print("Trigger Date is \(triggerDate)")
    let identifier = createLocalNotificationIdentifier(date: newDate, type: type)
    print("Local Notification Identifier: \(identifier)")

    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
        print("Added Local Notification Identifier: \(identifier)")
        trackEvent(category: "SDK", action: "Notification_Created", value: 1)
        if let error = error {
            print("Local Notification Error: \(error)")
        }
    })
}

func createLocalNotificationAt9AM(title:String, body:String, type:String, date:Date, userinfo: [AnyHashable: Any]){
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    content.badge = 1
    content.userInfo = userinfo
    //content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
    
    //Date Configuration
    var newDate = date
    if newDate.hour >= 9 {newDate = newDate.tomorrow}
    print("Date is \(date)")
    newDate.hour = 9
    newDate.minute = 0
    newDate.second = 0
    let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: newDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    //print("New Date is \(date)")
    print("Trigger Date is \(triggerDate)")
    
    let identifier = createLocalNotificationIdentifier(date: newDate, type: type)
    
    //Notification Information
    print("Local Notification Identifier: \(identifier)")
    print(date.dateString(ofStyle: .full))
    print(date.timeString(ofStyle: .short))
    
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
        print("Added Local Notification Identifier: \(identifier)")
        trackEvent(category: "SDK", action: "Notification_Created", value: 1)
        if let error = error {
            print("Local Notification Error: \(error)")
        }
    })
}

func createLocalNotificationAt9AM(title:String, body:String, type:String, userinfo: [AnyHashable: Any]){
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    content.badge = 1
    content.userInfo = userinfo
    //content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
    
    //Date Configuration
    var date = Date()
    if date.hour >= 9 {date = date.tomorrow}
    date.hour = 9
    date.minute = 0
    date.second = 0
    let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    //print("New Date is \(date)")
    print("Trigger Date is \(triggerDate)")

    let identifier = createLocalNotificationIdentifier(date: date, type: type)
    
    //Notification Information
    print("Local Notification Identifier: \(identifier)")
    print(date.dateString(ofStyle: .full))
    print(date.timeString(ofStyle: .short))
    
    //Remove Existing Notifications
    //removeLocalNotification(identifier: identifier)
    //getPendingNotifications()
    
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
        print("Added Local Notification Identifier: \(identifier)")
        trackEvent(category: "SDK", action: "Notification_Created", value: 1)
        if let error = error {
            print("Local Notification Error: \(error)")
        }
    })
}


func createLocalNotificationAt9AM(title:String, body:String, type:String, imageUrl:String, userinfo: [AnyHashable: Any]){
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    content.badge = 1
    content.userInfo = userinfo
    

//    guard let data = try? Data(contentsOf: URL(string: imageUrl)!) else { return }

    let data = try? Data(contentsOf: URL(string: imageUrl)!)

    if let data = data {
        if let attachment = UNNotificationAttachment.create(identifier: title, image: UIImage(data: data)!, options: nil) {
            content.attachments = [attachment]
        }
    }
    
    //content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
    
    //Date Configuration
    var date = Date()
    if date.hour >= 9 {date = date.tomorrow}
    date.hour = 9
    date.minute = 0
    date.second = 0
    let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    //print("New Date is \(date)")
    print("Trigger Date is \(triggerDate)")
    
    let identifier = createLocalNotificationIdentifier(date: date, type: type)
    
    //Notification Information
    print("Local Notification Identifier: \(identifier)")

    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
        print("Added Local Notification Identifier: \(identifier)")
        trackEvent(category: "SDK", action: "Notification_Created", value: 1)
        if let error = error {
            print("Local Notification Error: \(error)")
        }
    })
}




func createLocalNotificationIdentifier(date:Date, type:String) -> String{
    return "\(type)\(date.dateString(ofStyle: .short))"
}

func getPendingNotifications() {
    guard #available(iOS 10.0, *) else {return}
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        for r in requests {
            print("PendingNotificationRequest: \(r)")
        }
    }
}

func getDeliveredNotifications(){
    guard #available(iOS 10.0, *) else {return}
    UNUserNotificationCenter.current().getDeliveredNotifications{ notifications in
        for n in notifications {
            print("DeliveredNotifications: \(n)")
        }
    }
}

func getDeliveredNotificationsCount(){
    guard #available(iOS 10.0, *) else {return}
    UNUserNotificationCenter.current().getDeliveredNotifications{ notifications in
        print("Notification count is \(notifications.count)")
        DispatchQueue.main.async(execute: {
            UIApplication.shared.applicationIconBadgeNumber = notifications.count
        })
    }
}

func removeLocalNotification(identifier: String) {
    print("Remove Local Notification Identifier: \(identifier)")

    guard #available(iOS 10.0, *) else {return}
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
}

func removeAllLocalNotifications() {
    guard #available(iOS 10.0, *) else {return}
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
}

func removeDeliveredNotification(identifier: String) {
    print("Remove Delivered Notification Identifier: \(identifier)")

    guard #available(iOS 10.0, *) else {return}
    UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}

func removeAllDeliveredNotifications() {
    guard #available(iOS 10.0, *) else {return}
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
}

func handleNotification(userInfo:[AnyHashable: Any]) -> Void{
    // Print full message.
    print("Notifications userInfo Recieved: \(userInfo)")
    
    // Print all of userInfo
    for (key, value) in userInfo {
        print("userInfo: \(key) —> value = \(value)")
    }
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID Present: \(messageID)")
    }
    
    if let messageView = userInfo["view"] {
        print("Notifications View Recieved: \(messageView)")
    }
    
    AppDelegateKit.appDelegate.notificationFunction(userInfo: userInfo)
}

func connectToFcm() {
    // Won't connect since there is no token
//    guard InstanceID.instanceID().token() != nil else { return}
    
//    InstanceID.instanceID().instanceID { (result, error) in
//        if let error = error {
//            print("Error fetching remote instance ID: \(error)")
//        }
//        else if let result = result {
//            print("Remote instance ID token: \(result.token)")
//           // self.instanceIDTokenMessage.text  = "Remote InstanceID token: \(result.token)"
//            
//            
//        }
//    }
//    
//    // Disconnect previous FCM connection if it exists.
//    Messaging.messaging().disconnect()
//    
//    Messaging.messaging().connect { (error) in
//        if error != nil {print("Unable to connect with FCM. \(error?.localizedDescription ?? "")")}
//        else {print("Connected to FCM.")}
//    }
}


extension UNNotificationAttachment {
    
    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            guard let imageData = image.pngData() else {
                return nil
            }
            try imageData.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}

