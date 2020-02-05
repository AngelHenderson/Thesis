//
//  AuthenticationViewController.swift

//
//  Created by Angel Henderson on 1/19/18.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

//import TwitterKit
import FirebaseAuth
import Alamofire
import SwiftyJSON
import EasySocialButton
import IoniconsKit

import Closures

//Google Instruction
//https://firebase.google.com/docs/auth/ios/google-signin

//Facebook instructions
//https://firebase.google.com/docs/auth/ios/facebook-login


class AuthenticationViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Objects

    //@IBOutlet weak var googleButton1: GIDSignInButton!
    //@IBOutlet var coreFacebookButton = FBSDKLoginButton()
    
    @IBOutlet weak var dismissButton: UIButton?

    weak var coreFacebookButton: UIButton?
    @IBOutlet weak var signupButton: UIButton?
    @IBOutlet weak var loginButton: UIButton?
    
    @IBOutlet weak var updatePasswordButton: UIButton?
    @IBOutlet weak var forgotPasswordButton: UIButton?
    @IBOutlet weak var createAccountButton: UIButton?
    @IBOutlet weak var continueButton: UIButton?

    @IBOutlet weak var googleButton: AZSocialButton?
    @IBOutlet weak var facebookButton: AZSocialButton?

    @IBOutlet weak var emailAddressTextField: YoshikoTextField?
    @IBOutlet weak var emailView: UIView?

    @IBOutlet weak var passwordAddressTextField: YoshikoTextField?
    @IBOutlet weak var passwordView: UIView?

    @IBOutlet weak var backgroundView: UIView?

    @IBOutlet weak var appImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    
    @IBOutlet weak var signUpView1: UIView?
    @IBOutlet weak var signUpView2: UIView?
    @IBOutlet weak var signUpView3: UIView?

    @IBOutlet weak var confirmPasswordTextField: YoshikoTextField?
    @IBOutlet weak var codeTextField: YoshikoTextField?

    @IBOutlet weak var backLabel: UILabel?
    @IBOutlet weak var backImageView: UIImageView?
    @IBOutlet weak var backButton: UIButton?
    @IBOutlet weak var backView: UIView?

    @IBOutlet weak var orLabel: UILabel?

    @IBOutlet weak var reasonLabel: UILabel?

    var customAuthenication: Bool? = false

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordAddressTextField?.isSecureTextEntry = true
        confirmPasswordTextField?.isSecureTextEntry = true
        
        if #available(iOS 12.0, *) {
            confirmPasswordTextField?.textContentType = .newPassword
        } else {
            confirmPasswordTextField?.textContentType = .password
        }
        
        backImageView?.image = UIImage.ionicon(with: .arrowLeftC, textColor: .label, size: CGSize(width: 25, height: 25))
        backLabel?.textColor = .primaryTextColor
        orLabel?.textColor = .primaryTextColor

        signUpView1?.isHidden = true
        signUpView2?.isHidden = true
        signUpView3?.isHidden = true

        backView?.isHidden = true
        createAccountButton?.isHidden = true
        signupButton?.isHidden = false
        continueButton?.isHidden = true
        updatePasswordButton?.isHidden = true

        view.backgroundColor = .primaryBackgroundColor
        titleLabel?.textColor = .primaryTextColor
        reasonLabel?.textColor = .primaryTextColor
        
        loginButton?.backgroundColor = ColorKit.themeColor
        titleLabel?.text = AppCoreKit.appName
        appImageView?.image = AppCoreKit.appIcon
        
        //Reason
        self.reasonLabel?.text = authenicationCopy

        //Google Delegate
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self

//        GIDSignIn.sharedInstance().signIn()
        
        //Textfield Delegate
        emailAddressTextField?.delegate = self
        passwordAddressTextField?.delegate = self
        confirmPasswordTextField?.delegate = self
        codeTextField?.delegate = self

        dismissButton?.setImage(UIImage.ionicon(with: .close, textColor: .label, size: CGSize(width: 20, height: 20)), for: .normal)

        dismissButton?.onTap {
            self.dismiss(animated: true, completion: nil)
        }
        
        
        
        
        //Google Button
        googleButton?.backgroundColor = UIColor.groupTableViewBackground
        googleButton?.setTitleColor(.label, for: [])
        
        googleButton?.onTap {
            print("Google Signin")
            GIDSignIn.sharedInstance().signIn()
        }
        
        facebookButton?.onTap {
            
//            if let accessToken = AccessToken.current {
//                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
//                if self.customAuthenication == true {
//                    print("Facebook Sign Request")
//
//                    FBSDKGraphRequest(graphPath:"me", parameters: ["fields":"email"]).start(completionHandler: { (connection, result, error) in
//                        if error == nil {
//                            guard let data = result as? [String:Any] else { return }
//                            if let userEmail = data["email"] as! String? {
//                                print("Facebook Signing In \(userEmail)")
//                                self.authenication(email: userEmail, provider: credential.provider)
//                            }
//
//                        }
//                    })
//                }
//            }
            
            
            print("Facebook Signin")
            let loginManager = LoginManager()
            loginManager.logOut()
            self.firebaseSignout()

            loginManager.logIn(permissions: [.publicProfile, .email], viewController: self, completion: { loginResult in
                switch loginResult {
                case .failed(let error):
                    print("Facebook Error: ", error.localizedDescription)
                case .cancelled:
                    print("Facebook cancelled")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("Facebook success")
                    print("Facebook grantedPermissions: \(grantedPermissions)")
                    print("Facebook declinedPermissions: \(declinedPermissions)")

                    //let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)

                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
                    if self.customAuthenication == true {
                        print("Facebook Sign Request")
                        
                        GraphRequest(graphPath:"me", parameters: ["fields":"email"]).start(completionHandler: { (connection, result, error) in
                            if error == nil {
                                print("User Info : \(result)")
                                guard let data = result as? [String:Any] else { return }
                                
                                if let userEmail = data["email"] as! String? {
                                    print("Facebook Signing In \(userEmail)")
                                    self.authenication(email: userEmail, provider: credential.provider)
                                }
                                
                            } else {
                                print("Error Getting Info \(error)");
                            }
                        })
                    }
                    else {
                        self.firebaseLogin(credential)
                    }
                    print("Logged in!")
                }
                
                print("Facebook Sign Process Begins")
            })

        }
        
//        forgotPasswordButton?.onTap {
//            self.signUpView1?.isHidden = true
//        }
//
        backButton?.onTap {
            print("Back Button Tapped")
            self.signUpView1?.isHidden = true
            self.signUpView2?.isHidden = true
            self.signUpView3?.isHidden = true
            self.backView?.isHidden = true
            self.reasonLabel?.text = ""
            self.reasonLabel?.text = authenicationCopy
            self.createAccountButton?.isHidden = true
            self.continueButton?.isHidden = true
            self.updatePasswordButton?.isHidden = true

            
            self.loginButton?.isHidden = false
            self.passwordView?.isHidden = false
            self.signupButton?.isHidden = false
            self.forgotPasswordButton?.isHidden = false
        }
        
        forgotPasswordButton?.onTap {
            print("Forgot Password Tapped")
            self.passwordView?.isHidden = true
            self.loginButton?.isHidden = true
            self.reasonLabel?.text = "No problem. Please provide your email address, and we'll send you an email with a link to change your password."
            self.createAccountButton?.isHidden = true
            self.loginButton?.isHidden = true
            self.forgotPasswordButton?.isHidden = true
            self.signUpView3?.isHidden = true
            self.updatePasswordButton?.isHidden = true

            self.continueButton?.isHidden = false
            self.backView?.isHidden = false
            self.googleButton?.isHidden = false
            self.facebookButton?.isHidden = false

        }
        
        signupButton?.onTap {
            self.loginButton?.isHidden = true
            self.signupButton?.isHidden = true
            self.forgotPasswordButton?.isHidden = true
            self.continueButton?.isHidden = true
            self.signUpView3?.isHidden = true
            self.updatePasswordButton?.isHidden = true

            
            self.passwordView?.isHidden = false
            self.signUpView1?.isHidden = false
            self.signUpView2?.isHidden = false
            self.backView?.isHidden = false
            self.reasonLabel?.text = "Create an account below."
            self.createAccountButton?.isHidden = false
        }
        
        
        continueButton?.onTap {
            self.loginButton?.isHidden = true
            self.signupButton?.isHidden = true
            self.forgotPasswordButton?.isHidden = true
            self.continueButton?.isHidden = true
            self.signUpView3?.isHidden = true
            
            self.updatePasswordButton?.isHidden = false
            self.passwordView?.isHidden = false
            self.signUpView1?.isHidden = false
            self.signUpView2?.isHidden = false
            self.backView?.isHidden = false
            self.reasonLabel?.text = "Please enter the confirmation code and your new password below."
            self.createAccountButton?.isHidden = false
        }
    }

    
    //MARK: Firebase Signin (Credentials)
    func firebaseLogin(_ credential: AuthCredential) {
        if let user = Auth.auth().currentUser {
            user.linkAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    print("linkAndRetrieveData ",error.localizedDescription)
                    return
                }
            }
        }
        else {
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    print("signInAndRetrieveData ", error.localizedDescription)
                    return
                }
            }
        }
    }
    
    @IBAction func facebookAction(_ sender: AnyObject){
        facebookButton?.sendActions(for: .touchUpInside)
    }
    
    func authenication(email: String, password: String){
        
    }
    
    func authenication(email: String, provider: String){
        
    }
    
    //MARK: Custom Token Authenication
    
    func customTokenAuthentication(customToken: String) {
        
        Auth.auth().signIn(withCustomToken: customToken) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            print("User details ", user?.additionalUserInfo)
            print("User uid ", user?.user.uid)
            print("User email ", user?.user.email)
            showSuccessAlert(title: "Logged In", subtitle: "You have logged in")

            getNavigationController()?.popViewController(animated: true)
        }
    }
    
    func customTokenAuthentication(customToken: String, auth: Auth) {
        auth.signIn(withCustomToken: customToken) { (user, error) in
            if let error = error {
                print("Customtoken error ", error.localizedDescription)
                return
            }
            
            showSuccessAlert(title: "Logged In", subtitle: "You have logged in")
            getCurrentViewController()?.dismiss(animated: true, completion: {
                CommonKit.notificationPost(name: "customTokenAuthentication")
            })

        }
    }

    // MARK: - Memory Warning

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Text Field Delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        self.view.endEditing(true)
        return false
        //return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Firebase Signout
    func firebaseSignout(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }

}


// MARK: - Firebase Methods


// MARK: - Email Authenication

extension AuthenticationViewController {

    //MARK: Email Signin
    @IBAction func signInAction(_ sender: AnyObject){
        guard let emailAddress = emailAddressTextField?.text else {
            showErrorAlert(title: "Email address is empty", subtitle: "Please try again")
            return
        }
        
        guard let password = passwordAddressTextField?.text else {
            showErrorAlert(title: "Password is empty", subtitle: "Please try again")
            return
        }
        
        if emailAddress != "" || password != "" {
            authenication(email: emailAddress, password: password)
        }
        else {
            showErrorAlert(title: "Email address and/or password empty", subtitle: "Please try again")
        }
    }
    
}

//MARK: - Facebook Authenication
extension AuthenticationViewController {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        print("Facebook Sign Process Begins")
        

        if let error = error {
            print("Facebook Error: ", error.localizedDescription)
            return
        }
        
        print("Facebook Sign Process: \(result)")

        firebaseSignout()
        print("Facebook Error: ", error?.localizedDescription)

        
        if result?.isCancelled == true {
            print("Facebook Sign Cancelled")
            return
        }

        guard let tokenString = AccessToken.current?.tokenString else {
            showErrorAlert(title: "Facebook Error", subtitle: "Sign In failed, please try again later")
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)

        if customAuthenication == true {
            print("Facebook Sign Request")

            GraphRequest(graphPath:"me", parameters: ["fields":"email"]).start(completionHandler: { (connection, result, error) in
                if error == nil {
                    print("User Info : \(result)")
                    guard let data = result as? [String:Any] else { return }

                    if let userEmail = data["email"] as! String? {
                        print("Facebook Signing In \(userEmail)")
                        self.authenication(email: userEmail, provider: credential.provider)
                    }
                }
                else {
                    print("Error Getting Info \(error)");
                }
            })
        }
        else {
            firebaseLogin(credential)
        }
    }
    
    
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        firebaseSignout()
    }
    
}

//MARK: - Google Authenication


extension AuthenticationViewController: GIDSignInDelegate {
    
    //Old System
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if GIDSignIn.sharedInstance().handle(url) {
            return true
        }
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    // MARK: - Google Auth Delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        firebaseSignout()
        
        guard let authentication = user.authentication else { return }
        
        // Perform any operations on signed in user here.
//        let userId = user.userID                  // For client-side use only!
//        let idToken = user.authentication.idToken // Safe to send to the server
//        let fullName = user.profile.name
//        let givenName = user.profile.givenName
//        let familyName = user.profile.familyName
//        let email = user.profile.email
        
        
        //Google Credentials
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        if customAuthenication == true {
            authenication(email: user.profile.email, provider: credential.provider)
        }
        else {
            firebaseLogin(credential)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }
    
}


extension AuthenticationViewController: AuthUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
}
