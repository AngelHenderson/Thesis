//
//  HandsoffKit.swift
//
//  Created by Angel Henderson on 9/27/17.
//  Copyright © 2017 Angel Henderson Holding Corporation. All rights reserved.
//

import Foundation

func createUserActivity(activityType:String, title:String, userInfo:[String:Any], uniqueIdentifier:String){
    let userActivity = NSUserActivity(activityType: activityType)
    userActivity.title = title
    userActivity.userInfo = userInfo
}

