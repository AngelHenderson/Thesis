//
//  AudioManager.swift

//
//  Created by Angel Henderson on 9/14/17.
//  Copyright © 2017 Angel Henderson Holding Corporation. All rights reserved.
//

import Foundation
import NDAudioSuite
import MediaPlayer

// MARK: - DownloadAudio
func downloadFile(url: String, title: String) {AudioKit.downloadManager.downloadFile(from: URL(string: url)!, withName: title, andExtension: "mp3", completion: nil)}


struct AudioKit {
    
    // MARK: - MusicPlayerViewController
    
    static var setMusicPlayerViewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "MusicPlayerViewController") as! MusicPlayerViewController

    static var ndAudioPlayer: NDAudioPlayer = NDAudioPlayer()
    static var downloadManager: NDAudioDownloadManager = NDAudioDownloadManager()
    
    static var songList: [String] = []
    static var savedList: [Any] = []
    
    //Music Player
    static var currentTime: CGFloat = 0.0
    static var currentSongName: String!
    
    
    static func setupMusicPlayer(songTitle:String, albumTitle:String, imageUrl: String, encodedFileUrl:String){
        
        //loadingIndicator(text: "Loading")
        let tabBarController = AppDelegateKit.appDelegate.window?.rootViewController as? UITabBarController
        tabBarController?.closePopup(animated: false, completion: nil)
        let popupContentController = setMusicPlayerViewController
        popupContentController.songTitle = songTitle
        popupContentController.albumTitle = albumTitle
        popupContentController.albumArtUrl = imageUrl
        
        //Accessibility
        popupContentController.popupItem.accessibilityHint = NSLocalizedString("Double Tap to Expand the Mini Player", comment: "")
        tabBarController?.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString("Dismiss Now Playing Screen", comment: "")
        
        //Tabbar: User Interface
        tabBarController?.popupContentView.popupCloseButtonStyle = .chevron
        tabBarController?.popupContentView.popupCloseButton.alpha = 0
        tabBarController?.presentPopupBar(withContentViewController: popupContentController, animated: true, completion: nil)
        tabBarController?.popupBar.tintColor = ColorKit.themeColor
        
        //Play Audio
        playFileUrl(fileUrl: encodedFileUrl)
        dismissIndicator()
        
        //Analytics
        trackEvent(category: "Play", action: songTitle, value: 1)
    }
}



// MARK: - Play File
func playFileUrl(fileUrl:String) {
    let popupContentController: MusicPlayerViewController = AudioKit.setMusicPlayerViewController
    AudioKit.songList = [fileUrl]
    AudioKit.ndAudioPlayer.stopAudio()
    AudioKit.ndAudioPlayer.delegate = popupContentController
    AudioKit.ndAudioPlayer.isStopped = true
    AudioKit.ndAudioPlayer.isPlaying = false
    AudioKit.ndAudioPlayer.isPaused = false
    dismissIndicator()
    setCurrentVolume()  //Volume
    
    if AudioKit.songList.count != 0 {
        AudioKit.ndAudioPlayer.prepare(toPlay: NSMutableArray(array: AudioKit.songList), at: 0, atVolume: AudioKit.ndAudioPlayer.getAudioVolume())
        AudioKit.ndAudioPlayer.playAudio() //Play Audio
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNowPlaying"), object: nil)
    }

}

// MARK: - MusicPlayerViewController (Oneplace)

func setupMusicPlayer(songTitle:String, albumTitle:String, image: UIImage, encodedFileUrl:String){
    let tabBarController = AppDelegateKit.appDelegate.window?.rootViewController as? UITabBarController
    tabBarController?.closePopup(animated: false, completion: nil)
    let popupContentController: MusicPlayerViewController = AudioKit.setMusicPlayerViewController
    popupContentController.songTitle = songTitle
    popupContentController.albumTitle = albumTitle
    popupContentController.albumArtImageView?.image = image
    
    //Accessibility
    popupContentController.popupItem.accessibilityHint = NSLocalizedString("Double Tap to Expand the Mini Player", comment: "")
    tabBarController?.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString("Dismiss Now Playing Screen", comment: "")
    
    //Tabbar: User Interface
    tabBarController?.popupContentView.popupCloseButtonStyle = .chevron
    tabBarController?.popupContentView.popupCloseButton.alpha = 0
    tabBarController?.presentPopupBar(withContentViewController: popupContentController, animated: true, completion: nil)
    tabBarController?.popupBar.tintColor = ColorKit.themeColor
        
    //Play Audio
    playFileUrl(fileUrl: encodedFileUrl)
    dismissIndicator()
    
    //Analytics
}



// MARK: - Download

func downloadEpisode(url: String, title: String) {
    AudioKit.downloadManager.downloadFile(from: URL(string: url)!, withName: title, andExtension: "mp3", completion: nil)
}

func downloadCurrentTrack(songTitle: String){
    let indexString: String = AudioKit.songList[AudioKit.ndAudioPlayer.getCurrentTrackIndex()] as! String
    let url = NSURL(string: indexString)
    var songName = url?.lastPathComponent
    songName = AudioKit.downloadManager.removeExtension(fromFile: songName!)
    print("Downloading the Url \(String(describing: url)) and Title \(songTitle)")
    AudioKit.downloadManager.downloadFile(from: url! as URL, withName: songTitle, andExtension: "mp3", completion: nil)
    AudioKit.currentSongName = songTitle
    showBanner(title: "Download in Progress", subtitle: "Downloading the current episode for offline support")
}


// MARK: - Volume

func setMaxVolume() {
    AudioKit.ndAudioPlayer.setAudioVolume(1)
}

func setCurrentVolume() {
    let volume = AVAudioSession.sharedInstance().outputVolume
    AudioKit.ndAudioPlayer.setAudioVolume(CGFloat(volume))
}

// MARK: - Player Status

func playerIsStopped() {
    AudioKit.ndAudioPlayer.isStopped = true
    AudioKit.ndAudioPlayer.isPlaying = false
    AudioKit.ndAudioPlayer.isPaused = false
}

func playerIsPlaying() {
    AudioKit.ndAudioPlayer.isStopped = false
    AudioKit.ndAudioPlayer.isPlaying = true
    AudioKit.ndAudioPlayer.isPaused = false
}
func playerIsPaused() {
    AudioKit.ndAudioPlayer.isStopped = false
    AudioKit.ndAudioPlayer.isPlaying = false
    AudioKit.ndAudioPlayer.isPaused = true
}


// MARK: - AudioPlayer Delegate

extension MusicPlayerViewController: NDAudioPlayerDelegate, NDAudioDownloadManagerDelegate {
    @objc func backgroundAudioSetup() {
        print("backgroundAudioSetup")
        if AudioKit.ndAudioPlayer.isPaused || AudioKit.ndAudioPlayer.isStopped {AudioKit.ndAudioPlayer.pauseAudio()}
    }
    
    func audioManagerSetup() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(MusicPlayerViewController.backgroundAudioSetup), name: Notification.Name(rawValue:"AudioKit"), object: nil)

        remoteCommandCenterSetup()
        // Set up Audio Player
       // playerIsStopped()
       // playerIsPlaying()
        let playData = UIImage(named: "nowPlaying_play")!.pngData()

        let pauseData = UIImage(named: "nowPlaying_pause")!.pngData()
        if let original = playButton?.imageForNormal?.original {
            
            let compareImageData = original.pngData()
            
            if let pauseImage = pauseData, let compareTo = compareImageData, let playImage = playData {
                
                if pauseImage == compareTo {
                    print("Image is currently pause")
                    playerIsPlaying()
                }
                else if playImage == compareTo {
                    print("Image is currently play")
                    playerIsStopped()
                }
                else{
                    playerIsPlaying()
                    print("Empty image is not equal to image1.image")
                }
            }
        }
        
        

        

        
        setCurrentVolume()
        
        // Set up Download Manager
        AudioKit.downloadManager.delegate = self
        AudioKit.ndAudioPlayer.delegate = self
    }
    
    func ndAudioPlayerIsReady(_ sender: NDAudioPlayer) {
        print("the audio player is ready")
        
        if AudioKit.ndAudioPlayer.isPaused {
            AudioKit.ndAudioPlayer.pauseAudio()
            return
        }
        
        print("ndAudioPlayerIsReady")
        
        progressSlider?.setValue(0.0, animated: true)
        popupItem.progress = 0.0;
        popupItem.accessibilityProgressLabel = NSLocalizedString("Playback Progress", comment: "")
        self.putInformationInSongInfoCenter()
        //AudioKit.ndAudioPlayer.playAudio()
    }
    
    func ndAudioPlayerTimeIsUpdated(_ sender: NDAudioPlayer, withCurrentTime currentTime: CGFloat) {
        AudioKit.currentTime = currentTime
        //progressSlider?.setValue(Float(currentTime/AudioKit.ndAudioPlayer.getTotalDuration()), animated: true)
        
        popupItem.progress = Float(currentTime/AudioKit.ndAudioPlayer.getTotalDuration());
        popupItem.accessibilityProgressLabel = NSLocalizedString("Playback Progress", comment: "")
        
        progressView?.progress = popupItem.progress
        progressSlider?.setValue(popupItem.progress, animated: true)
        
        let totalFloat = AudioKit.ndAudioPlayer.getTotalDuration()
        if (totalFloat.isNaN || totalFloat.isInfinite || totalFloat == 0) {
            //loadingIndicator(text:"Loading Episode")
        }
        else {
            let totalTime: Int = Int(Float(AudioKit.ndAudioPlayer.getTotalDuration())/60)
            let currentTimeMinutes: Int = Int(currentTime/60)
            let totalTimeSeconds: Int = Int(AudioKit.ndAudioPlayer.getTotalDuration()) % 60
            let currentTimeSeconds: Int = Int(currentTime) % 60
            currentLabel?.text = String(format: "%i:%02d", currentTimeMinutes, currentTimeSeconds)
            finalLabel?.text = String(format: "%i:%02d", totalTime, totalTimeSeconds)
        }
        
        let r = currentTime.truncatingRemainder(dividingBy: 5.0)
        let y = Int(r);
        
        //Record Track Duration
        if (y == 0 && r != 0) {
            if let analyticsValue = analytics {trackEvent(category: "PlayDuration", action: analyticsValue, value: 5)}
            else {
                if let show = showTitle {trackEvent(category: "PlayDuration", action: show, value: 5)}
                else {trackEvent(category: "PlayDuration", value: 5)}
            }
        }
        
        self.putInformationInSongInfoCenter()
        
        if AudioKit.ndAudioPlayer.isPaused && stillPlaying == true {
            stillPlaying = false
            let play = UIBarButtonItem(image: UIImage(named: "play"), style: .plain, target: self, action: #selector(pauseAction(sender:)))
            play.accessibilityLabel = NSLocalizedString("Play", comment: "")
            self.popupItem.leftBarButtonItems = [ play ]
            playButton?.setImage(UIImage(named: "nowPlaying_play"), for: UIControl.State.normal)
        }
        else if AudioKit.ndAudioPlayer.isPlaying && stillPlaying == false {
            stillPlaying = true
            let pause = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: self, action: #selector(pauseAction(sender:)))
            pause.accessibilityLabel = NSLocalizedString("Pause", comment: "")
            self.popupItem.leftBarButtonItems = [ pause ]
            playButton?.setImage(UIImage(named: "nowPlaying_pause"), for: UIControl.State.normal)
        }
    }
    
    func ndAudioPlayerPlaylistIsDone(_ sender: NDAudioPlayer) {
        popupPresentationContainer?.dismissPopupBar(animated: true, completion: nil)
    }
    
    func ndAudioPlayerTrackIsDone(_ sender: NDAudioPlayer, nextTrackIndex index: Int) {
    }
    
    func ndAudioDownloadManager(_ sender: NDAudioDownloadManager, currentDownloadIsCompleteWithRemainingDownloads count: UInt) {
        print("the audio player is done downloading")
        showTempAlert(title: "Download Successful", subtitle: "This episode has been saved")

        AudioKit.savedList = AudioKit.downloadManager.getAllDownloadedFiles(withExtension: "mp3")!
        dismissIndicator()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "downloadComplete"), object: nil)
    }
}

// MARK: Remote Command Center

func remoteCommandCenterSetup(){
    //Remote Command Center - https://developer.apple.com/reference/mediaplayer/mpremotecommandcenter
    UIApplication.shared.beginReceivingRemoteControlEvents()
    
    let remoteCommandCenter = MPRemoteCommandCenter.shared()
    
    let togglePlayPauseCommand = remoteCommandCenter.togglePlayPauseCommand
    togglePlayPauseCommand.isEnabled = true
    togglePlayPauseCommand.addTarget(handler: playPause)
    
    let skipBackwardCommand = remoteCommandCenter.skipBackwardCommand
    skipBackwardCommand.isEnabled = true
    skipBackwardCommand.addTarget(handler: skipBackward)
    skipBackwardCommand.preferredIntervals = [15]
    
    let skipForwardCommand = remoteCommandCenter.skipForwardCommand
    skipForwardCommand.isEnabled = true
    skipForwardCommand.addTarget(handler: skipForward)
    skipForwardCommand.preferredIntervals = [15]
    
    let playCommand = remoteCommandCenter.playCommand
    playCommand.isEnabled = true
    playCommand.addTarget(handler: play)
    
    let pauseCommand = remoteCommandCenter.pauseCommand
    pauseCommand.isEnabled = true
    pauseCommand.addTarget(handler: pause)
}

func playPause(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    AudioKit.ndAudioPlayer.isPlaying == true ? AudioKit.ndAudioPlayer.pauseAudio() : AudioKit.ndAudioPlayer.playAudio()
    return .success
}

func skipBackward(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    guard let command = event.command as? MPSkipIntervalCommand else {
        return .noSuchContent
    }
    
    let interval = command.preferredIntervals[0]
    AudioKit.ndAudioPlayer.rewind(toTime: AudioKit.currentTime - CGFloat(interval))
    AudioKit.currentTime -= 15
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNowPlaying"), object: nil)
    return .success
}

func skipForward(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    guard let command = event.command as? MPSkipIntervalCommand else {
        return .noSuchContent
    }
    
    let interval = command.preferredIntervals[0]
    AudioKit.ndAudioPlayer.fastForward(toTime: AudioKit.currentTime + CGFloat(interval))
    AudioKit.currentTime += 15
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNowPlaying"), object: nil)
    return .success
}

func play(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    AudioKit.ndAudioPlayer.playAudio()
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNowPlaying"), object: nil)
    return .success
}

func pause(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    AudioKit.ndAudioPlayer.pauseAudio()
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNowPlaying"), object: nil)
    return .success
}
