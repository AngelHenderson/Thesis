//
//  AppStoreReviewKit.swift
//
//  Created by Angel Henderson on 9/28/17.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import Foundation
import StoreKit
import Times

extension AppStoreReviewKit {
    static var minimumRunCount = 8
    static var showDebug = true
}


struct AppStoreReviewKit {
    static var runIncrement = "numberOfAppRuns"

    // counter for number of runs for the app
    static func incrementAppRuns() {
        let runs = getRunCounts() + 1
        setUserDefault(int: runs, key: AppStoreReviewKit.runIncrement)
        syncUserDefault()
    }
    
    // Reads number of runs from UserDefaults and returns it.
    static func getRunCounts () -> Int {
        let savedRuns = getUserDefaultInteger(key: AppStoreReviewKit.runIncrement)
        return savedRuns!
    }
    
    static func resetRunCounts() {setUserDefault(int:0, key: AppStoreReviewKit.runIncrement)}
    
    static func execute() {
        let runs = getRunCounts()
        
        if AppStoreReviewKit.showDebug == true {
            print("Run count is \(runs)")
        }
        
        if (runs > AppStoreReviewKit.minimumRunCount) {
            if AppStoreReviewKit.showDebug == true {print("Review Requested")}
            
            Times.shared.times(3, forKey: "appReview") {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AppStoreReview"), object: nil)
                resetRunCounts()
            }
        }
        else {incrementAppRuns()}
    }
    
    static func promptReview() {NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AppStoreReview"), object: nil)}
}






