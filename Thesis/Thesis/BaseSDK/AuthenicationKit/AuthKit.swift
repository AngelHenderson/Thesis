//
//  AuthKit.swift

//
//  Created by Angel Henderson on 5/25/18.

//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import SwiftyJSON

//Google Instruction
//https://firebase.google.com/docs/auth/ios/google-signin

struct AuthKit {

   
    
}

extension AuthKit {
    
    // MARK: - Anonymously

//    static func signInAnonymously(){
//        
//
//        Auth.auth().signInAnonymously() { (authResult, error) in
//            let user = authResult?.user
//            let isAnonymous = user?.isAnonymous  // true
//            let uid = user?.uid
//            
//        }
//    }
    
    // MARK: - Facebook
    
    func facebookAuthentication(authenication: AuthenticationViewController) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email"], from: authenication, handler: { (result, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else if result!.isCancelled {
                print("FBLogin cancelled")
            }
            else {
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current?.tokenString ?? result?.token?.tokenString ?? "")
                authenication.firebaseLogin(credential)
            }
        })
    }
    
    // MARK: - Google
    
    func googleAuthentication(authenication: AuthenticationViewController) {
        GIDSignIn.sharedInstance()?.presentingViewController = authenication
        GIDSignIn.sharedInstance().signIn()
    }
    
    // MARK: - Twitter
    
    func twitterAuthentication() {
        //        Twitter.sharedInstance().logIn() { (session, error) in
        //            if let session = session {
        //                let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
        //                AuthKit.firebaseLogin(credential)
        //            }
        //            else {print(error.localizedDescription)}
        //        }
    }
    
    
    // MARK: - Phone Number
    
    func phoneNumberAuthentication(customToken: String) {
        Auth.auth().signIn(withCustomToken: customToken) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            getNavigationController()?.popViewController(animated: true)
        }
    }
    
    // MARK: - Custom Token
    

    
    // MARK: - Email
    
    func emailAuthentication(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            getNavigationController()?.popViewController(animated: true)
        }
    }
    
    func didRequestPasswordReset(email: String, password: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Sent")
        }
    }
    
    func createAccount(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard let email = authResult?.user.email, error == nil else {
                print(error!.localizedDescription)
                return
            }
            print("\(email) created")
            getNavigationController()?.popViewController(animated: true)
        }
    }
    
    func didGetProvidersForEmail(email: String, password: String) {
        Auth.auth().fetchProviders(forEmail: email) { (providers, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print(providers!.joined(separator: ", "))
        }
    }
}



