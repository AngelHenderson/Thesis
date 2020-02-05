//
//  ReachabilityKit.swift

//
//  Created by Angel Henderson on 9/14/17.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import Foundation
import Reachability

// MARK: - Reachability

struct ReachabilityKit {
    
    static var reachability: Reachability?

    static func setupReachability(_ hostName: String?) {
        let reachability: Reachability?

        if let hostName = hostName {
            reachability = try? Reachability(hostname: hostName)
        } else {
            reachability = try? Reachability()
        }
        ReachabilityKit.reachability = reachability
        
        startNotifier()
    }
    
    func setupReachability(_ hostName: String?) {
        let reachability: Reachability?
        if let hostName = hostName {
            reachability = try? Reachability(hostname: hostName)
        } else {
            reachability = try? Reachability()
        }
        ReachabilityKit.reachability = reachability
    }
    
    static func startNotifier() {
        do {try ReachabilityKit.reachability?.startNotifier()}
        catch {return}
    }
    
    static func stopNotifier() {
        ReachabilityKit.reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(AppDelegateKit.appDelegate, name: Notification.Name.reachabilityChanged, object: nil)
        ReachabilityKit.reachability = nil
    }
    
    // MARK: - Check Reachability
    
    static func checkReachability(){
        guard ReachabilityKit.reachability?.connection != Reachability.Connection.none else {
            showInternetErrorBanner()
            return
        }
    }
}



