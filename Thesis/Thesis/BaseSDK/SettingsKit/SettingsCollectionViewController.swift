//
//  SettingsCollectionViewController.swift

//
//  Created by Angel Henderson on 8/9/17.
//  Copyright © 2017 Angel Henderson. All rights reserved.
//

import UIKit
import SizeClasser
import SwiftyJSON
import Alamofire
import SafariServices
import BRYXBanner

import WhatsNewKit

// MARK: - Configurable Functions

let reuseIdentifier = "SettingCollectionViewCell"



class SettingsCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    func row1Function(){additionalSettingsRowFunction1()}
    func row2Function(){additionalSettingsRowFunction2()}
    func row3Function(){additionalSettingsRowFunction3()}
    func row4Function(){additionalSettingsRowFunction4()}
    func row5Function(){additionalSettingsRowFunction5()}
    func row6Function(){additionalSettingsRowFunction6()}
    
    var sizeClasser = SizeClasser()
    @IBOutlet var collectionView: UICollectionView?
    @IBOutlet weak var navigationView:NavigationView?
    @IBOutlet weak var centerView: UIView?

    lazy var bottomSheetPresentationManager = BottomSheetPresentationManager()

    var signedOutUserArray = ["Sign in", "Notifications", "Rate this App", "Share this App", "What's New"]
    var signedInUserArray = ["Logout", "Notifications", "Rate this App", "Share this App", "What's New"]
    var supportArray = ["Terms of Service", "Contact Us"]
    var settingHeadersArray = ["General", "Support", "Messages"]
    var resetArray = ["Delete Messages"]
    
    //Optional
    var additionalSettingsSectionTitle: String?
    var additionalSettingsArray:[String?] = []
    
    func additionalSettingsRowFunction1(){}
    
    func additionalSettingsRowFunction2(){}
    
    func additionalSettingsRowFunction3(){}
    
    func additionalSettingsRowFunction4(){}
    
    func additionalSettingsRowFunction5(){}
    
    func additionalSettingsRowFunction6(){}

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadNotification), name: NSNotification.Name(rawValue: "Signup"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadNotification), name: NSNotification.Name(rawValue: "Signout"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.resetMessageCompleted), name: NSNotification.Name(rawValue: "resetMessages"), object: nil)
        
        collectionView?.register(UINib(nibName: "SettingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SettingCollectionViewCell")
        collectionView?.register(UINib(nibName: "SwitchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SwitchCollectionViewCell")        
        collectionView?.register(UINib(nibName: "SettingsCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SettingsCollectionReusableView")

    }
    
    override func viewWillAppear(_ animated: Bool) {

        collectionView?.backgroundColor = .primaryBackgroundColor
        view.backgroundColor = .primaryBackgroundColor
        collectionView?.reloadData()
        trackScreen(name: "Settings View")
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSplit()
    }
    
    @objc func reloadNotification(notification: NSNotification) {
        self.collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func resetMessagePage() {
        let messageCenterResetPrompt = MessageCenterResetPrompt(nibName: "SingleChoiceWithImageViewController", bundle: nil)
        messageCenterResetPrompt.titleString = "Delete Messages"
        messageCenterResetPrompt.subjectString = "Are you sure you would like to delete all messages?"
        messageCenterResetPrompt.choiceImage = AppCoreKit.appIcon.cornerRadiusImage()
        messageCenterResetPrompt.firstButton?.backgroundColor = ColorKit.themeColor
        messageCenterResetPrompt.firstButtonString = "Yes"
        messageCenterResetPrompt.cancelButtonString = "Cancel"
        messageCenterResetPrompt.transitioningDelegate = bottomSheetPresentationManager
        messageCenterResetPrompt.modalPresentationStyle = .custom
        CommonKit.getCurrentViewController()?.present(messageCenterResetPrompt, animated: true, completion: nil)
    }
    
    @objc func resetMessageCompleted(){
        print("resetMessageCompleted")
        trackEvent(category: "Reset Messages", value: 1)
        for document in messagesSnapshot {
            messageCenterDeletedArray.append((document?.documentID)!)
        }
        setUserDefault(object:messageCenterDeletedArray, key:messageCenterDeletedArrayKey)
        syncUserDefault()
    
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resetCount"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resetList"), object: nil)
        showTempAlert(title: "Messages Deleted", subtitle: "Your messages have all been deleted.")
    }
    

    // MARK: - Size Class
    
    func updateSplit(for traitCollection: UITraitCollection? = nil) {
        guard let trait = SizeClasser(traitCollection: traitCollection ?? super.traitCollection) else { return }
        if self.sizeClasser != trait {
            collectionView?.reloadItems(at: (collectionView?.indexPathsForVisibleItems)!)
            self.sizeClasser = trait
        }
        else {return}
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

    // MARK: - Actions
    

    func openContact(){
        trackEvent(category: "Contact Us", value: 1)
        let svc = SFSafariViewController(url: URL(string: AppCoreKit.contactUsUrl)!)
        present(svc, animated: true, completion: nil)
    }
    
    func openTerms(){
        trackEvent(category: "Terms of Service", value: 1)
        let svc = SFSafariViewController(url: URL(string: AppCoreKit.termsOfUseUrl)!)
        present(svc, animated: true, completion: nil)
    }
    
    func rateMyApp(){
        trackEvent(category: "Rate App", value: 1)
        DialogPrompt.requestAppReviewPage()
        
    }
    
    func shareMyApp(){
        trackEvent(category: "Share App", value: 1)
        let contentToShare = [AppCoreKit.appStoreText, AppCoreKit.appStoreUrl] as [Any]
        let activityViewController = UIActivityViewController(activityItems: contentToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.centerView
        activityViewController.popoverPresentationController?.sourceRect = centerView?.frame ?? self.view.frame
        present(activityViewController, animated: true, completion: nil)
    }
    
    func resetMessage(){
        trackEvent(category: "Reset Message Center", value: 1)
        resetMessagePage()
    }
    
    func signInAction(){
        if (UserKit.checkUserStatus()) {
            print("Signing User Out")
            UserKit.signOutUser()
        }
        else {
            print("Signing User In")
            AppDelegateKit.appDelegate.signInLogic()
        }
    }
    

    
    func notificationPressed(){
        if isRegisteredForRemoteNotifications() == true {
            print("Notification permission granted")
        }
        else {
            print("Notification permission not granted")
            DialogPrompt.requestPushNotificationPage(description: "The app has not been given permission to grant notifications. Would you like to grant the app permission?")
        }
    }
    
    func stateChanged(switchState: UISwitch) {
        if switchState.isOn {
            //myTextField.text = "The Switch is On"
        } else {
            //myTextField.text = "The Switch is Off"
        }
    }
}

extension SettingsCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return signedInUserArray.count
        case 1:
            return supportArray.count
        case 2:
            return resetArray.count
        case 3:
            return additionalSettingsArray.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: SettingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingCollectionViewCell", for: indexPath) as! SettingCollectionViewCell
        cell.bottomView?.backgroundColor = .secondaryBackgroundColor

        switch indexPath.section {
        case 0:
            let array = UserKit.checkUserStatus() == true ? signedInUserArray:signedOutUserArray
            if indexPath.row == 0 {
                let title = UserKit.checkUserStatus() == true ? "Log Out": "Sign In"
                cell.titleLabel?.text = title
                return cell
            }
            else if indexPath.row == 1 {
                let cell: SwitchCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwitchCollectionViewCell", for: indexPath) as! SwitchCollectionViewCell
                cell.titleLabel?.text = array[indexPath.row]
                if isRegisteredForRemoteNotifications() == true {
                    print("Notification permission granted")
                    if (getUserDefaultBool(key: notificationKey) == true) {cell.notificationSwitch?.setOn(true, animated:true)}
                    else {cell.notificationSwitch?.setOn(false, animated:false)}
                }
                else {
                    print("Notification permission not granted")
                    turnOffNotification()
                    cell.notificationSwitch?.setOn(false, animated: false)
                }
                
                cell.bottomView?.backgroundColor = .secondaryBackgroundColor
                return cell
            }
            cell.titleLabel?.text = array[indexPath.row]
        case 1:
            cell.titleLabel?.text = supportArray[indexPath.row]
        case 2:
            cell.titleLabel?.text = resetArray[indexPath.row]
        case 3:
            cell.titleLabel?.text = additionalSettingsArray[indexPath.row]
        default:
            cell.titleLabel?.text = ""
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 45
        
        //Night Mode Configuration
        if indexPath.row == 2 && indexPath.section == 0 && AppCoreKit.supportNightMode == false {height = 0}
        
        return cellSizeConfiguration(width: self.view.frame.size.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil        
        if (kind == UICollectionView.elementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SettingsCollectionReusableView", for: indexPath as IndexPath) as! SettingsCollectionReusableView
            headerView.titleLabel.text = indexPath.section == 3 ? additionalSettingsSectionTitle : settingHeadersArray[indexPath.section]
            headerView.titleLabel.textColor = ColorKit.themeColor
            reusableView = headerView
        }
        return reusableView!
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "showPage1", sender: self)
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                signInAction()
                break
            case 1:
                if isRegisteredForRemoteNotifications() == true {
                    print("Notification permission granted")
                    let cell: SwitchCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwitchCollectionViewCell", for: indexPath) as! SwitchCollectionViewCell
                    if (getUserDefaultBool(key: notificationKey) == true) {
                        print("Notification switch set to false")
                        cell.notificationSwitch?.setOn(false, animated:true)
                        turnOffNotification()
                    }
                    else {
                        print("Notification switch set to true")
                        cell.notificationSwitch?.setOn(true, animated:true)
                        turnOnNotification()
                        DispatchQueue.main.async(execute: {
                            //UIApplication.shared.registerForRemoteNotifications()
                            requestNotificationSetup()
                        })
                    }
                    collectionView.reloadData()
                }
                else {
                    print("Notification permission not granted")
                    DialogPrompt.requestPushNotificationPage(description: "The app has not been given permission to grant notifications. Would you like to grant the app permission?")
                }
                break
            case 2:
                rateMyApp()
                break
            case 3:
                shareMyApp()
                break
            case 4:
                var configuration = WhatsNewViewController.Configuration()
                configuration.completionButton.backgroundColor = ColorKit.themeColor
                configuration.apply(animation: .fade)
                self.present(WhatsNewViewController(whatsNew: WhatsNewKit.Default, configuration: configuration), animated: true, completion: nil)
                break
            default:
                break
            }
        }
        else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                openTerms()
                break
            case 1:
                openContact()
                break
            default:
                break
            }
        }
        else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                resetMessage()
                break
            default:
                break
            }
        }
        else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                row1Function()
                break
            case 1:
                row2Function()
                break
            case 2:
                row3Function()
                break
            case 3:
                row4Function()
                break
            case 4:
                row5Function()
                break
            case 5:
                row6Function()
                break
            default:
                break
            }
        }
    }
}


