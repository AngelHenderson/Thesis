//
//  AnalyticsKit.swift
//
//  Created by Angel Henderson on 8/11/17.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAnalytics
import FBSDKCoreKit


extension AnalyticsKit {
    static var UAToken: String? //Google Analytics
    static var googleAnalyticsSupported: Bool? = true
    static var firebaseAnalyticsSupported: Bool? = true
    static var facebookAnalyticsSupported: Bool? = true
}

//MARK: - Global Methods
func trackEvent(category: String, action: String, label: String, value: NSNumber?) {AnalyticsKit.trackEvent(category: category, action: action, label: label, value: value)}
func trackEvent(category: String, action: String, value: NSNumber?) {AnalyticsKit.trackEvent(category: category, action: action, value: value)}
func trackEvent(category: String, value: NSNumber?) {AnalyticsKit.trackEvent(category: category, value: value)}
func trackScreen(name: String) {AnalyticsKit.trackScreen(name: name)}
func trackUserProperty(key: String, value: String) {AnalyticsKit.trackUserPropery(key: key, value: value)}
func trackUserId(userID: String) {AnalyticsKit.trackUserId(userID: userID)}

// MARK: - Analytics

struct AnalyticsKit {
    //MARK: - Methods

    static func trackEvent(category: String, action: String, label: String, value: NSNumber?) {
//        if googleAnalyticsSupported == true {
//            guard let tracker = GAI.sharedInstance().tracker(withTrackingId: UAToken) else { return }
//            let trackDictionary = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value)
//            tracker.send(trackDictionary?.build() as [NSObject : AnyObject]?)
//        }


        if facebookAnalyticsSupported == true {
            AppEvents.logEvent(AppEvents.Name(rawValue: category), valueToSum: value as! Double, parameters: ["action": action as String, AppEvents.ParameterName.content.rawValue: action, AppEvents.ParameterName.contentID.rawValue: label, AppEvents.ParameterName.contentType.rawValue: category])
        }
        
        
        if firebaseAnalyticsSupported == true {
            let cleanCategory = category.withoutSpacesAndNewLines.replacingOccurrences(of: "-", with: "_")
            let cleanAction = action.withoutSpacesAndNewLines.replacingOccurrences(of: "-", with: "_")
            let cleanLabel = label.withoutSpacesAndNewLines.replacingOccurrences(of: "-", with: "_")

            Analytics.logEvent(cleanCategory, parameters: ["action": cleanAction, AnalyticsParameterItemName: cleanAction, AnalyticsParameterContentType: cleanCategory, AnalyticsParameterItemID: cleanLabel])
        }
    }
    
    static func trackEvent(category: String, action: String, value: NSNumber?) {
//        if googleAnalyticsSupported == true {
//            guard let tracker = GAI.sharedInstance().tracker(withTrackingId: UAToken) else { return }
//            let trackDictionary = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: nil, value: value)
//            tracker.send(trackDictionary?.build() as [NSObject : AnyObject]?)
//        }
//
        if firebaseAnalyticsSupported == true {
            let cleanCategory = category.withoutSpacesAndNewLines.replacingOccurrences(of: "-", with: "_")
            let cleanAction = action.withoutSpacesAndNewLines.replacingOccurrences(of: "-", with: "_")
            Analytics.logEvent(cleanCategory, parameters: ["action": cleanAction, AnalyticsParameterItemName: cleanAction, AnalyticsParameterContentType: cleanCategory])
        }
        
        if facebookAnalyticsSupported == true {
            AppEvents.logEvent(AppEvents.Name(rawValue: category), parameters: ["action": action as String, AppEvents.ParameterName.content.rawValue: action, AppEvents.ParameterName.contentType.rawValue: category])
        }
    }
    
    static func trackEvent(category: String, value: NSNumber?) {
//        if googleAnalyticsSupported == true {
//            guard let tracker = GAI.sharedInstance().tracker(withTrackingId: UAToken) else { return }
//            let trackDictionary = GAIDictionaryBuilder.createEvent(withCategory: category, action: nil, label: nil, value: value)
//            tracker.send(trackDictionary?.build() as [NSObject : AnyObject]?)
//        }

        if firebaseAnalyticsSupported == true {
            let cleanCategory = category.withoutSpacesAndNewLines.replacingOccurrences(of: "-", with: "_")
            Analytics.logEvent(cleanCategory, parameters: [AnalyticsParameterItemName: cleanCategory])
        }
        
        if facebookAnalyticsSupported == true {
            AppEvents.logEvent(AppEvents.Name(rawValue: category), parameters: [AppEvents.ParameterName.contentType.rawValue: category])
        }
    }
    
    // MARK: Track Screen
    static func trackScreen(name: String) {
//        if googleAnalyticsSupported == true {
//            guard let tracker = GAI.sharedInstance().tracker(withTrackingId: UAToken) else { return }
//            tracker.set(kGAIScreenName, value: name)
//            let build = (GAIDictionaryBuilder.createScreenView().build() as NSDictionary) as! [AnyHashable: Any]
//            tracker.send(build)
//        }

        if firebaseAnalyticsSupported == true {
            let cleanName = name.withoutSpacesAndNewLines.replacingOccurrences(of: "-", with: "_")
            Analytics.logEvent(cleanName, parameters: [AnalyticsParameterItemName: cleanName])
        }
    }
    
    
    // MARK: User Properties
    static func trackUserPropery(key: String, value: String) {
        if firebaseAnalyticsSupported == true {
            let cleanKey = key.withoutSpacesAndNewLines.replacingOccurrences(of: "-", with: "_")
            let cleanValue = value.withoutSpacesAndNewLines.replacingOccurrences(of: "-", with: "_")
            Analytics.setUserProperty(cleanValue, forName: cleanKey)
        }
    }
    
    // MARK: User ID
    static func trackUserId(userID: String) {
        if firebaseAnalyticsSupported == true {
            Analytics.setUserID(userID.withoutSpacesAndNewLines.replacingOccurrences(of: "-", with: "_"))
        }
    }
}


