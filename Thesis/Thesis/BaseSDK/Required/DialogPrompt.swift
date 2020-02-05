//
//  DialogPrompt.swift

//
//  Created by Angel Henderson on 8/16/17.
//  Copyright © 2017 Angel Henderson. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import StoreKit


// MARK: - Bulletin Board

struct DialogPrompt {
    static var bottomSheetPresentationManager = BottomSheetPresentationManager()

    // MARK: - App Review

    static func requestAppReviewPage() {
        let appStoreReviewPrompt = AppStoreReviewPrompt(nibName: "SingleChoiceWithImageViewController", bundle: nil)
        appStoreReviewPrompt.titleString = "Enjoying \(AppCoreKit.appName)?"
        appStoreReviewPrompt.subjectString = "If you enjoy using \(AppCoreKit.appName), would you mind taking a moment to rate it? Thank you for your support!"
        appStoreReviewPrompt.choiceImage = AppCoreKit.appIcon.cornerRadiusImage()
        appStoreReviewPrompt.firstButton?.backgroundColor = ColorKit.themeColor
        appStoreReviewPrompt.firstButtonString = "Rate \(AppCoreKit.appName) App"
        appStoreReviewPrompt.cancelButtonString = "Not now"
        appStoreReviewPrompt.transitioningDelegate = DialogPrompt.bottomSheetPresentationManager
        appStoreReviewPrompt.modalPresentationStyle = .custom
        CommonKit.getCurrentViewController()?.present(appStoreReviewPrompt, animated: true, completion: nil)
    }
    
    static func requestPushNotificationPage(description:String) {
        let requestNotificationPrompt = RequestNotificationPrompt(nibName: "SingleChoiceWithImageViewController", bundle: nil)
        requestNotificationPrompt.titleString = "Push Notifications"
        requestNotificationPrompt.subjectString = description
        requestNotificationPrompt.choiceImage = AppCoreKit.appIcon.cornerRadiusImage()
        requestNotificationPrompt.firstButton?.backgroundColor = ColorKit.themeColor
        requestNotificationPrompt.firstButtonString = "Subscribe"
        requestNotificationPrompt.cancelButtonString = "Not now"
        requestNotificationPrompt.transitioningDelegate = DialogPrompt.bottomSheetPresentationManager
        requestNotificationPrompt.modalPresentationStyle = .custom
        CommonKit.getCurrentViewController()?.present(requestNotificationPrompt, animated: true, completion: nil)
    }
}
