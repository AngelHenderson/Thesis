//
//  UserKit.swift

//
//  Created by Angel Henderson on 3/29/18.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseAuth


var userAuthorizationHeader: String?

struct UserKit {
    
    // MARK: - User Authorization
    static func userAuthorizated(){
        guard isUserSignedIn() == true else {return}
    }
    
    // MARK: - User Status
    static func isUserSignedIn() -> Bool {
        return (Auth.auth().currentUser != nil) ? true : false
    }
    
    // MARK: - Recieve Authorization Header
    static func userAuthorization() -> HTTPHeaders {
        var headers: HTTPHeaders = [:]
        headers["Authorization"] = userAuthorizationHeader
        return headers
    }
    
    static func signInUser() {

    }
    
    static func checkUserStatus() -> Bool {
        if Auth.auth().currentUser != nil && Auth.auth().currentUser?.isAnonymous == false {return true}
        else {return false}
    }
    
    //Sign Out User
    static func signOutUser() {
        userAuthorizationHeader = ""

        //Analytics: User Properties
        trackUserProperty(key: "UsersSignedIn", value: "false")
        trackUserProperty(key: "SignedIn", value: "false")

        showTempAlert(title: "Logged Off Successfully", subtitle: "You are now logged off")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Signout"), object: nil)

        //Firebase SignOut
        do {try Auth.auth().signOut()}
        catch let signOutError as NSError {print ("Error signing out Local: %@", signOutError)}
        
        //Firebase Signin Anonymously
        //signInAnonymously()
        
        //Post Notification
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Signup"), object: nil)

    }
    
//    static func signInAnonymously() {
//        guard Auth.auth().currentUser == nil else {return}
//
//        Auth.auth().signInAnonymously(){ (authResult, error) in
////            let user = authResult?.user
////            let isAnonymous = user?.isAnonymous  // true
////            let uid = user?.uid
//        }
//    }
}
