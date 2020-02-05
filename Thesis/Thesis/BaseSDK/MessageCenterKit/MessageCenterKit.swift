//
//  MessageCenterKit.swift

//
//  Created by Angel Henderson on 8/16/17.
//  Copyright © 2017 Angel Henderson. All rights reserved.
//

import Foundation
import Firebase
import SwifterSwift
import FirebaseFirestore

var messagesSnapshot: [DocumentSnapshot?] = []

var messageCenterKeysArray: [String] = []
var messageCenterReadArray:[String] = []
var messageCenterDeletedArray:[String] = []

let messageCenterArrayKey = "\(AppCoreKit.bundleIdentifier).messageCenterArray"
let messageCenterDeletedArrayKey = "\(AppCoreKit.bundleIdentifier).messageCenterDeletedArray"

func initiateMessageCenter(){
    
    getMessageCenterChangesFromiCloud()
    
    let database = Firestore.firestore()
    let settings = database.settings
    settings.areTimestampsInSnapshotsEnabled = true
    database.settings = settings
    
    database.collection("messages").order(by: "timestamp", descending: true).getDocuments() { (document, err) in
        if let err = err {print("Error getting documents: \(err)")}
        else {
            messagesSnapshot = document!.documents
            updateMessageCenterKeys()
            
        }
    }
}

func updateMessageCenterKeys() {
    messageCenterKeysArray = []
    
    //Retrieve Message Center Keys
    //for key in messagesSnapshot { messageCenterKeysArray.append(key)}
    
    for document in messagesSnapshot {
        messageCenterKeysArray.append((document?.documentID)!)
    }
    
    //Remove Delete Messages from Message Center Keys
    removeDeletedMessagesFromMessageCenterKey()
    
    //Set Order of Keys
    //messageCenterKeysArray.sort{ $0.compare($1, options: .numeric) == .orderedDescending}
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "messageCenterDatabaseChange"), object: nil)

}


func getMessageCenterChangesFromiCloud() {
    //Locally Sets Message Center Array
    if let key = getUserDefaultObject(key:messageCenterArrayKey){messageCenterReadArray = key as! [String]}
    else {setUserDefault(object:[], key:messageCenterArrayKey)}
    
    //Sets Array of Messages Deleted By User
    if let key = getUserDefaultObject(key: messageCenterDeletedArrayKey){messageCenterDeletedArray = key as! [String]}
    else {setUserDefault(object:[], key:messageCenterDeletedArrayKey)}
    syncUserDefault()
}

func removeDeletedMessagesFromMessageCenterKey(){
    //Removes Deleted Messages From Message Center
    for i in messageCenterDeletedArray {messageCenterKeysArray.removeAll(i)}
    messageCenterKeysArray.removeDuplicates()
}

func updateMessageCenterBadgeCount() -> Int {
    var unreadCount = 0
    for i in messageCenterKeysArray {
        if (messageCenterReadArray.contains(i) == false) {
            unreadCount += 1
        }
    }
    return unreadCount
}

// MARK: Message Center Actions

func messageReadFromMessageCenter(key: String){
    trackEvent(category: "Message Center", action: "Selected", value: 1)

    //Adds the Key to the Read Array
    if let readArray = getUserDefaultObject(key:messageCenterArrayKey){
        messageCenterReadArray = readArray as! [String]
        messageCenterReadArray.append(key)
        messageCenterReadArray = messageCenterReadArray.withoutDuplicates()
        setUserDefault(object:messageCenterReadArray, key:messageCenterArrayKey)
        syncUserDefault()
    }
    
    //Update App Count Badge and Update Badge Count
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "messageCenterDatabaseChange"), object: nil)
}

func messageMarkedAsUnreadFromMessageCenter(key: String){
    trackEvent(category: "Message Center", action: "Mark as Unread", value: 1)
    
    //Removes the Key to the Read Array
    messageCenterReadArray.removeAll(key)
    setUserDefault(object:messageCenterReadArray.withoutDuplicates(), key:messageCenterArrayKey)
    syncUserDefault()

    //Update App Count Badge and Update Badge Count
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "messageCenterDatabaseChange"), object: nil)
}

func messageDeletedFromMessageCenter(key: String){
    trackEvent(category: "Message Center", action: "Deleted", value: 1)

    //Adds the Key to the Read Array
    if let readArray = getUserDefaultObject(key:messageCenterArrayKey){
        messageCenterReadArray = readArray as! [String]
        messageCenterReadArray.append(key)
        messageCenterReadArray = messageCenterReadArray.withoutDuplicates()
        setUserDefault(object:messageCenterReadArray, key:messageCenterArrayKey)
    }

    //Adds the Key to the Deleted Array
    if let deleteArray = getUserDefaultObject(key:messageCenterDeletedArrayKey){
        messageCenterDeletedArray = deleteArray as! [String]
        messageCenterDeletedArray.append(key)
        messageCenterDeletedArray = messageCenterDeletedArray.withoutDuplicates()
        setUserDefault(object:messageCenterDeletedArray, key:messageCenterDeletedArrayKey)
    }

    syncUserDefault()
    removeDeletedMessagesFromMessageCenterKey()

    //Update App Count Badge and Update Badge Count
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "messageCenterDatabaseChange"), object: nil)
}
