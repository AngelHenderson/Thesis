//
//  VideoKit.swift
//
//  Created by Angel Henderson on 6/13/18.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import Foundation
import MediaPlayer
import AVFoundation
import AVKit

//MARK: - VideoKit Methods

struct VideoKit{
    static func playVideo(videoUrl: String) {
        dismissIndicator()
        let videoURL = URL(string: videoUrl)!
        AppDelegateKit.appDelegate.avPlayer = AVPlayer(url: videoURL)
        AppDelegateKit.appDelegate.avPlayerViewController.player = AppDelegateKit.appDelegate.avPlayer
        CommonKit.getCurrentViewController()?.present(AppDelegateKit.appDelegate.avPlayerViewController, animated: true, completion: {
            AppDelegateKit.appDelegate.avPlayerViewController.player?.play()
            AppDelegateKit.appDelegate.setupVideoRemoteCommandCenterSetup()
        })
    }
}
