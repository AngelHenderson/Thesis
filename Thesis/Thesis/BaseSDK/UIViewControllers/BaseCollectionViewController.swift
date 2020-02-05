//
//  BaseCollectionViewController.swift
//  iOSSalemSDKSample
//
//  Created by Angel Henderson on 3/24/18.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import DeckTransition
import Reachability
import CoreSpotlight
import MobileCoreServices
import AEAppVersion
import SizeClasser

import IoniconsKit
import Bartinter
import EmptyStateKit

func internetConnection() -> Bool {
    if (ReachabilityKit.reachability?.connection == Reachability.Connection.none){
        return false
    }
    else {
        return true
    }
}

extension BaseCollectionViewController {
    
    //Optional
    @objc func primaryEndpointFunction(){}
    
    //Useable Functions
    func jsonRequest(dataRequest:DataRequest?){loadDataRequest(dataRequest: dataRequest)}
}


class BaseCollectionViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView?
    @IBOutlet var navigationView: NavigationView?
    @IBOutlet var backgroundView: BackgroundView?
    var json:JSON?
    
    var automatedLoadingIndicators: Bool = true

    //Navigation View
    var navigationTitle = "Home"
    var navigationSubTitle = ""
    var navigationImageIcon: UIImage = UIImage.ionicon(with: .iosArrowDown, textColor: .label, size: CGSize(width: 25, height: 25))
    var navigationImageIconSize: CGFloat = 25
    
    // MARK: - Cache
    var cacheSupport: Bool = false
    
    //Responsive Design
    var sizeClasser = SizeClasser()

    //Handoff
    var activity: NSUserActivity = NSUserActivity(activityType: generalActivityKey)
    var userActivityInfo:String = ""
     
    override func viewDidLoad() {
        

        setupNotificationCenter()
        
        //Checks for new app version
        switch AEAppVersion.shared.state {
        case .new:
            print("Clean Install")
            if getUserDefaultBool(key: "\(AEAppVersion.versionAndBuild)") == false {

                setUserDefault(bool: true, key: "\(AEAppVersion.versionAndBuild)")
            }
        case .update(let previousVersion):
            print("Update from: \(previousVersion)")
            if getUserDefaultBool(key: "\(AEAppVersion.versionAndBuild)") == false {

                setUserDefault(bool: true, key: "\(AEAppVersion.versionAndBuild)")
            }
        case .rollback(let previousVersion):
            print("Rollback from: \(previousVersion)")

            setUserDefault(bool: true, key: "\(AEAppVersion.versionAndBuild)")
        case .equal:
            print("Not Changed")
            //if let bulletin = cleanInstallIntro(){showBulletin(page:bulletin)}
        }
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        statusBarUpdater?.refreshStatusBarStyle()

        CoreSpotlight.getSpotlightArray()
        //createUserActivity(activityType:generalActivityKey, title:navigationSubTitle)
        
        navigationView?.setup(title: navigationTitle, subject: navigationSubTitle, image: UIImage.ionicon(with: .arrowDownA, textColor: UIColor.label, size: CGSize(width: navigationImageIconSize, height: navigationImageIconSize)))
        internetConnectionCheck()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSplit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if automatedLoadingIndicators {
            dismissIndicator()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Bartinter
    
    override var childForStatusBarStyle: UIViewController? {
        return statusBarUpdater
    }
    
    override func setNeedsStatusBarAppearanceUpdate() {
        super.setNeedsStatusBarAppearanceUpdate()
        loadViewIfNeeded()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        statusBarUpdater?.refreshStatusBarStyle()
    }
    
    // MARK: - Data Request
    
    func loadJson(json:JSON?) {
        guard let requestedJSON = json else {return}
        self.json = requestedJSON
        //print("Load JSON: \(requestedJSON)")
        // if let handoffUserActivity = userActivity{ self.updateUserActivityState(handoffUserActivity) }
        collectionView?.reloadData()
        collectionView?.alpha = 1
        if automatedLoadingIndicators {
            dismissIndicator()
        }
    }
    
    func loadDataRequest(dataRequest:DataRequest?) {
        
        if cacheSupport == true {
            //Get cache response using request object
            if let cacheResponse = URLCache.shared.cachedResponse(for: (dataRequest?.request)!){
                //check if cached response is available if nil then hit url for data
                if cacheResponse != nil {
                    //let string = NSString(data: cacheResponse!.data, encoding: String.Encoding.utf8.rawValue)
                    //print("Cache JSON is: \(string ?? "Empty")")
                    self.loadJson(json: JSON(cacheResponse.data as Any))
                }
            }
        }
        
        if let request = dataRequest {
            request.responseJSON { response in
                if self.cacheSupport == true {
                    if let responseResponse = response.response, let responseData = response.data {
                        let cachedURLResponse = CachedURLResponse(response: responseResponse, data: ((responseData as NSData) as Data), userInfo: nil, storagePolicy: .allowed)
                        URLCache.shared.storeCachedResponse(cachedURLResponse, for: response.request!)
                    }
                }
                
                switch response.result {
                case .success(let value):
                    if self.automatedLoadingIndicators {
                        dismissIndicator()
                    }
                    self.loadJson(json: JSON(value))
                case .failure(let error):
                    print("loadDataRequest \(error)")
                    if self.automatedLoadingIndicators {
                        dismissIndicator()
                    }
                }
            }
        }
    }

    
    // MARK: - Notification Center

    func setupNotificationCenter() {
        //Endpoint Monitoring
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadNotification), name: NSNotification.Name(rawValue: navigationTitle), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.nightUpdate), name: NSNotification.Name(rawValue: "NightNightThemeChangeNotification"), object: nil)

        
        //Message Center Monitoring
        NotificationCenter.default.addObserver(self, selector: #selector(self.databaseChanged(_:)), name: NSNotification.Name(rawValue: "messageCenterDatabaseChange"), object: nil)
        
        //Reachibility Monitoring
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: ReachabilityKit.reachability)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadNotification), name: NSNotification.Name(rawValue: "Signup"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadNotification), name: NSNotification.Name(rawValue: "Signout"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.requestAppStoreReview), name: NSNotification.Name(rawValue: "AppStoreReview"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
    }
    
    @objc func requestAppStoreReview(notification: NSNotification) {
        DialogPrompt.requestAppReviewPage()
    }
    
    
    @objc func reloadNotification(notification: NSNotification) {
        collectionView?.reloadData()
        if automatedLoadingIndicators {dismissIndicator()}
    }
    
    @objc func reloadData(notification: NSNotification) {
        collectionView?.reloadData()
        if automatedLoadingIndicators {dismissIndicator()}
    }
    
    @objc func nightUpdate(notification: NSNotification) {
    }
    
    // MARK: - Reachability

    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        if reachability.isReachable {
            primaryEndpointFunction()
            collectionView?.alpha = 1
            viewWillAppear(true)
        }
        else {
            internetConnectionCheck()
        }
        collectionView?.reloadData()
    }
    
    func internetConnectionCheck(){
        if (ReachabilityKit.reachability?.connection == .none){
            if automatedLoadingIndicators {dismissIndicator()}
        }
    }
    


    
    
    // MARK: - Message Center Monitoring
    @objc func databaseChanged(_ notification: NSNotification) {
        
    }
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension BaseCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "BasicCollectionViewCell", for: indexPath) as! BasicCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    //UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSizeConfiguration(width: self.view.frame.size.width, height: 75)
    }
}

// MARK: - CoreSpotLight and Handoff

extension BaseCollectionViewController: NSUserActivityDelegate {
    
    func createUserActivity(activityType:String, title:String){
        let activity = NSUserActivity(activityType: activityType)
        activity.title = title
        activity.userInfo = ["navigationTitle": "", "navigationSubTitle": "", "json": ""]
        userActivity = activity
        userActivity?.becomeCurrent()
    }
    
    func userActivityWillSave(_ userActivity: NSUserActivity) {
        guard let activityJSON:JSON = json else {return}
        userActivity.userInfo = ["navigationTitle": navigationTitle, "navigationSubTitle": navigationSubTitle, "info":userActivityInfo]
        print("userActivityWillSave")
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        if let activityNavigationTitle: String = activity.userInfo?["navigationTitle"] as? String{navigationTitle = activityNavigationTitle}
        if let activityNavigationSubTitle: String = activity.userInfo?["navigationSubTitle"] as? String{navigationSubTitle = activityNavigationSubTitle}
        guard let activityJSON: JSON = activity.userInfo?["json"] as? JSON else {return}

        self.userActivity?.invalidate()
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        guard let activityJSON:JSON = json else {return}
        self.activity.userInfo = ["navigationTitle": navigationTitle, "navigationSubTitle": navigationSubTitle, "info":userActivityInfo]
        self.activity.title = navigationTitle
        //activity.addUserInfoEntries(from: ["navigationTitle": navigationTitle, "navigationSubTitle": navigationSubTitle, "json": json!])
        self.activity.isEligibleForHandoff = true
        self.activity.isEligibleForSearch = true
        self.activity.isEligibleForPublicIndexing = true
        
        //Required
        //activity.webpageURL
        self.activity.delegate = self
        self.activity.needsSave = true
        userActivity = self.activity
        userActivity!.becomeCurrent()
        
        // activity.addUserInfoEntries(from: ["navigationTitle": navigationTitle, "navigationSubTitle": navigationSubTitle, "json": activityJSON])
        print("Updated UserActivity with \(userActivity?.userInfo)")
        super.updateUserActivityState(userActivity!)
    }
    

}

// MARK: - Responsive Design

extension BaseCollectionViewController {
    
    func updateSplit(for traitCollection: UITraitCollection? = nil) {
        guard let trait = SizeClasser(traitCollection: traitCollection ?? super.traitCollection) else {return}
        if self.sizeClasser != trait {
            self.sizeClasser = trait
            collectionView?.reloadItems(at: (collectionView?.indexPathsForVisibleItems)!)
        }
        else {return}
    }
    

    
}
