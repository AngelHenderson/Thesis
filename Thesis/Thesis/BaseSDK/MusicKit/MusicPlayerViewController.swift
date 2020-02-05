//
//  MusicPlayerViewController.swift

//
//  Created by Angel Henderson on 1/27/17.
//  Copyright © 2017 Angel Henderson Holding Corporation. All rights reserved.
//

import UIKit
import MediaPlayer

import EFAutoScrollLabel
import SwiftyJSON
import Alamofire
import BRYXBanner
import NDAudioSuite
import Imaginary
import SwifterSwift

extension MusicPlayerViewController {

}

class MusicPlayerViewController: UIViewController {
    //Configurable Functions
    func saveActionFunction(){}
    func shareActionFunction(frame:CGRect){}
    func downloadFunction(){}
    func downloadCompletedFunction(){}
    func downloadEpisodeNotification(_ notification: NSNotification) {}

    @IBOutlet var songNameLabelScroll: EFAutoScrollLabel? = EFAutoScrollLabel()
    @IBOutlet var albumNameLabelScroll: EFAutoScrollLabel? = EFAutoScrollLabel()
    @IBOutlet weak var progressView: UIProgressView?
    @IBOutlet weak var albumArtImageView: UIImageView?

    @IBOutlet weak var volumeView: UIView?
    @IBOutlet weak var airPlayView: UIView?

    @IBOutlet weak var volumeSlider: UISlider?
    @IBOutlet weak var progressSlider: UISlider?

    @IBOutlet weak var playButton: UIButton?
    @IBOutlet weak var podcastPlayButton: UIButton?

    @IBOutlet weak var previousButton: UIButton?
    @IBOutlet weak var nextButton: UIButton?
    @IBOutlet weak var downloadButton: UIButton?
    @IBOutlet weak var backButton: UIButton?

    @IBOutlet weak var currentLabel: UILabel?
    @IBOutlet weak var finalLabel: UILabel?
    var showTitle: String?
    var analytics: String?

    var stillPlaying:Bool = false
    var volumeChanging: Bool = false

    var timer : Timer?

    let accessibilityDateComponentsFormatter = DateComponentsFormatter()
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        let pause = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: self, action: #selector(pauseAction(sender:)))
//        pause.accessibilityLabel = NSLocalizedString("Pause", comment: "")
//        let next = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .plain, target: self, action: #selector(forwardAction(sender:)))
//        next.width = 0.0
//        next.accessibilityLabel = NSLocalizedString("Next Track", comment: "")
//        self.popupItem.leftBarButtonItems = [ pause ]
//        self.popupItem.rightBarButtonItems = [ next ]
//        accessibilityDateComponentsFormatter.unitsStyle = .spellOut
//    }
    
    var songTitle: String = "" {
        didSet {
            if isViewLoaded { songNameLabelScroll?.text = songTitle }
            popupItem.title = songTitle
        }
    }
    var albumTitle: String = "" {
        didSet {
            if isViewLoaded { albumNameLabelScroll?.text = albumTitle }
            popupItem.subtitle = albumTitle
        }
    }
        
    var albumArt: UIImage = UIImage() {
        didSet {
            albumArtImageView?.image = albumArt
            popupItem.image = albumArt
            popupItem.accessibilityImageLabel = NSLocalizedString("Album Art", comment: "")
        }
    }
    
    var albumArtUrl: String = "" {
        didSet {
            albumArtImageView?.setImage(url: URL(string: albumArtUrl)!, placeholder:  UIImage(color: .groupTableViewBackground, size: (self.albumArtImageView?.frame.size)!)) { result in
                switch result {
                case .value(let image):
                    if self.popupItem.image != nil {
                        self.popupItem.image = image
                    }
                case .error(let error):
                    print("albumArtUrl \(error)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pause = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: self, action: #selector(pauseAction(sender:)))
        pause.accessibilityLabel = NSLocalizedString("Pause", comment: "")
        let next = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .plain, target: self, action: #selector(forwardAction(sender:)))
        next.width = 0.0
        next.accessibilityLabel = NSLocalizedString("Next Track", comment: "")
        self.popupItem.leftBarButtonItems = [ pause ]
        self.popupItem.rightBarButtonItems = [ next ]
        accessibilityDateComponentsFormatter.unitsStyle = .spellOut
        

        NotificationCenter.default.addObserver(self, selector: #selector(self.putInformationInSongInfoCenter), name: NSNotification.Name(rawValue: "updateNowPlaying"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadCompleted), name: NSNotification.Name(rawValue: "downloadComplete"), object: nil)
        
        audioManagerSetup()
        AudioKit.ndAudioPlayer.delegate = self

        albumArtImageView?.image = UIImage(color: .groupTableViewBackground, size: (self.albumArtImageView?.frame.size)!)
        albumArtImageView?.image = albumArt
        
        progressSlider?.minimumTrackTintColor = ColorKit.themeColor
        progressSlider?.maximumTrackTintColor = .groupTableViewBackground
        let icon = UIImage.ionicon(with: .record, textColor: ColorKit.themeColor, size: CGSize(width: 20, height: 20))

        progressSlider?.setThumbImage(icon, for: . normal)
        
        backButton?.setTitleColorForAllStates(ColorKit.themeColor)
        
        if (albumArtUrl != ""){
            albumArtImageView?.setImage(url: URL(string: albumArtUrl)!, placeholder:  UIImage(color: .groupTableViewBackground, size: (self.albumArtImageView?.frame.size)!)) { result in
                switch result {
                case .value(let image):
                    if self.popupItem.image != nil {
                        self.popupItem.image = image
                    }
                case .error(let error):
                    print("viewDidLoad \(error)")
                }
            }
        }
        
    }
    
    func configureScrollableLabels(){
        songNameLabelScroll?.text = songTitle
        songNameLabelScroll?.labelSpacing = 30
        songNameLabelScroll?.pauseInterval = 1.7
        songNameLabelScroll?.scrollSpeed = 30
        songNameLabelScroll?.textAlignment = NSTextAlignment.center
        songNameLabelScroll?.fadeLength = 12
        songNameLabelScroll?.observeApplicationNotifications()
        //songNameLabelScroll?.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
        //songNameLabelScroll?.scrollDirection = AutoScrollDirection.Left
        
        albumNameLabelScroll?.text = albumTitle
        albumNameLabelScroll?.labelSpacing = UIScreen.main.bounds.width
        albumNameLabelScroll?.pauseInterval = 1.7
        albumNameLabelScroll?.scrollSpeed = 30
        albumNameLabelScroll?.textAlignment = NSTextAlignment.center
        albumNameLabelScroll?.fadeLength = 12
        albumNameLabelScroll?.observeApplicationNotifications()
        albumNameLabelScroll?.textColor = ColorKit.themeColor
        //albumNameLabelScroll?.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
        //albumNameLabelScroll?.scrollDirection = AutoScrollDirection.Left
        
//        volumeSlider?.onChange{float in
//
//
//        }
        
//        volumeSlider?.on(.touchDragEnter){_,_  in
//            self.volumeChanging = true
//        }
//
//        volumeSlider?.on(.){_,_  in
//            self.volumeChanging = true
//        }
//
//        volumeSlider?.on
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        trackScreen(name: "Music Player View")

        configureScrollableLabels()

        songNameLabelScroll?.scrollLabelIfNeeded()
        albumNameLabelScroll?.scrollLabelIfNeeded()

        //Volume Controls
        let volumeControlView = MPVolumeView(frame: (volumeView?.bounds)!)
        volumeControlView.tintColor = ColorKit.themeColor
        //volumeControlView.setRouteButtonImage(Ionicons.iosMonitor.image(35, color: UIColor(red:0.13, green:0.43, blue:1.00, alpha:1.00)), for: .normal)
        volumeControlView.setRouteButtonImage(#imageLiteral(resourceName: "broadcast").af_imageAspectScaled(toFit: CGSize(width: 24, height: 24)), for: .normal)
        volumeControlView.contentMode = .scaleAspectFit
        volumeControlView.showsVolumeSlider = true
        volumeControlView.showsRouteButton = false
        //volumeControlView.setVolumeThumbImage(#imageLiteral(resourceName: "volUp").af_imageAspectScaled(toFit: CGSize(width: 24, height: 24)), for: .normal)
//        volumeControlView.setVolumeThumbImage(#imageLiteral(resourceName: "volDown").af_imageAspectScaled(toFit: CGSize(width: 28, height: 28)), for: .normal)
//        volumeControlView.routeButtonRect(forBounds: (volumeView?.bounds)!)
        
        if let volumeSliderView = volumeControlView.subviews.first as? UISlider {
            volumeSliderView.minimumValueImage = #imageLiteral(resourceName: "volDown").af_imageAspectScaled(toFit: CGSize(width: 10, height: 10))
            volumeSliderView.maximumValueImage = #imageLiteral(resourceName: "volUp").af_imageAspectScaled(toFit: CGSize(width: 16, height: 16))
        }
        volumeView?.addSubview(volumeControlView)
        volumeView?.backgroundColor = .clear
        
        let airPlayControlView = MPVolumeView(frame: (airPlayView?.bounds)!)
        airPlayControlView.tintColor = ColorKit.themeColor
        //volumeControlView.setRouteButtonImage(Ionicons.iosMonitor.image(35, color: UIColor(red:0.13, green:0.43, blue:1.00, alpha:1.00)), for: .normal)
        airPlayControlView.setRouteButtonImage(#imageLiteral(resourceName: "broadcast").af_imageAspectScaled(toFit: CGSize(width: 24, height: 24)), for: .normal)
        airPlayControlView.contentMode = .scaleAspectFit
        airPlayControlView.showsVolumeSlider = false
        airPlayControlView.showsRouteButton = true
        airPlayControlView.routeButtonRect(forBounds: (airPlayView?.bounds)!)
        airPlayView?.addSubview(airPlayControlView)
        airPlayView?.backgroundColor = .clear
        
        progressSlider?.addTarget(self, action: #selector(self.onSliderValChanged(sender:forEvent:)), for: UIControl.Event.valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(self.volumeChanged(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        
        audioManagerSetup()
        
        volumeSlider?.value = AVAudioSession.sharedInstance().outputVolume
        volumeSlider?.minimumTrackTintColor = ColorKit.themeColor
        volumeSlider?.maximumTrackTintColor = .groupTableViewBackground
        
        //ndAudioPlayerIsReady(ndAudioPlayer)
        progressSlider?.setValue(0.0, animated: true)
        popupItem.progress = 0.0;
        popupItem.accessibilityProgressLabel = NSLocalizedString("Playback Progress", comment: "")
        
        putInformationInSongInfoCenter()
        
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.beginReceivingRemoteControlEvents()

    }
    

    
    
    @objc func volumeChanged(notification: NSNotification) {
        print("Volume Changing \(volumeChanging)")

        if volumeChanging == false {
            let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
            
            print("VolumeChanged \(volume)")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                self.volumeSlider?.value =  volume
            }
        }
        
        volumeChanging = false

    }
    
    func sliderDidEndSliding() {
        AudioKit.ndAudioPlayer.playAudio()
        

    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {

        volumeChanging = true
        AudioKit.ndAudioPlayer.setAudioVolume(CGFloat(sender.value))
//        let volumeView = MPVolumeView()
//        for view in volumeView.subviews {
//            if (NSStringFromClass(view.classForCoder) == "MPVolumeSlider") {
//                let slider = view as! UISlider
//                slider.setValue(sender.value, animated: false)
//            }
//        }
        
       MPVolumeView.setVolume(sender.value)
        print("sliderValueChanged \(volumeChanging)")

    }
    
    @IBAction func progressSliderValueChanged(sender: UISlider) {
        let play = UIBarButtonItem(image: UIImage(named: "play"), style: .plain, target: self, action: #selector(pauseAction(sender:)))
        play.accessibilityLabel = NSLocalizedString("Play", comment: "")
        self.popupItem.leftBarButtonItems = [ play ]
        playButton?.setImage(UIImage(named: "nowPlaying_play"), for: UIControl.State.normal)
        podcastPlayButton?.setImage(UIImage(named: "nowPlaying_play"), for: UIControl.State.normal)

        
        AudioKit.ndAudioPlayer.fastForward(toTime:  CGFloat(Double(Double(sender.value) * Double(AudioKit.ndAudioPlayer.getTotalDuration()))))
        AudioKit.currentTime = CGFloat(Double(Double(sender.value) * Double(AudioKit.ndAudioPlayer.getTotalDuration())))
        putInformationInSongInfoCenter()
    
    }

    @objc func onSliderValChanged(sender: UISlider, forEvent: UIEvent) {
        let allTouches = forEvent.allTouches;
        if((allTouches?.count)! > 0) {
            let phase = (allTouches!.first as UITouch?)!.phase;

            switch (phase) {
            case UITouch.Phase.began:
                playSetup()
                break
            case UITouch.Phase.ended:
                AudioKit.ndAudioPlayer.playAudio()
                break
            case UITouch.Phase.moved:
                AudioKit.ndAudioPlayer.fastForward(toTime:  CGFloat(Double(Double(sender.value) * Double(AudioKit.ndAudioPlayer.getTotalDuration()))))
                AudioKit.currentTime = CGFloat(Double(Double(sender.value) * Double(AudioKit.ndAudioPlayer.getTotalDuration())))
                self.putInformationInSongInfoCenter()
                break
                
            default:
                break
            }
        }
    }

    @IBAction func forwardSeek(sender: UIButton) {
        AudioKit.ndAudioPlayer.fastForward(toTime: AudioKit.currentTime + 15)
        AudioKit.currentTime += 15
        putInformationInSongInfoCenter()
    }
    
    @IBAction func rewindSeek(sender: UIButton) {
        AudioKit.ndAudioPlayer.rewind(toTime: AudioKit.currentTime - 15)
        AudioKit.currentTime -= 15
        putInformationInSongInfoCenter()
    }
    
    func _timerTicked(_ timer: Timer) {
        if (currentLabel?.text == "0:01")  {timer.invalidate()}
        if popupItem.progress >= 1.0 {
            timer.invalidate()
            popupPresentationContainer?.dismissPopupBar(animated: true, completion: nil)
        }
    }
    
    @IBAction func shareButtonClicked(sender: UIButton) {
        ReachabilityKit.checkReachability()
        trackEvent(category: "Share", value: 1)
        let frame = sender.superview?.convert(sender.frame, to: self.view)
        shareActionFunction(frame:frame!)
    }
    
    @objc func forwardAction(sender: UIBarButtonItem) {
        AudioKit.ndAudioPlayer.fastForward(toTime: AudioKit.currentTime + 15)
        AudioKit.currentTime += 15
        putInformationInSongInfoCenter()
    }

    @IBAction func saveAction(_ sender: AnyObject){
        saveActionFunction()
    }
    
    @IBAction func pauseButtonAction(_ sender: AnyObject){
        print(AudioKit.ndAudioPlayer.isPlaying)
        if AudioKit.ndAudioPlayer.isPlaying { playSetup() }
        else {
            pauseSetup()
            self.changeLabel()
        }
    }
    
    @objc func pauseAction(sender: UIBarButtonItem) {
        if AudioKit.ndAudioPlayer.isPlaying { playSetup() }
        else { pauseSetup() }
    }
    
    func pauseSetup(){
        let pause = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: self, action: #selector(pauseAction(sender:)))
        pause.accessibilityLabel = NSLocalizedString("Pause", comment: "")
        self.popupItem.leftBarButtonItems = [pause]
        playButton?.setImage(UIImage(named: "nowPlaying_pause"), for: UIControl.State.normal)
        podcastPlayButton?.setImage(UIImage(named: "nowPlaying_pause"), for: UIControl.State.normal)
        AudioKit.ndAudioPlayer.playAudio()
    }
    
    func playSetup(){
        let play = UIBarButtonItem(image: UIImage(named: "play"), style: .plain, target: self, action: #selector(pauseAction(sender:)))
        play.accessibilityLabel = NSLocalizedString("Play", comment: "")
        self.popupItem.leftBarButtonItems = [play]
        playButton?.setImage(UIImage(named: "nowPlaying_play"), for: UIControl.State.normal)
        podcastPlayButton?.setImage(UIImage(named: "nowPlaying_play"), for: UIControl.State.normal)
        AudioKit.ndAudioPlayer.pauseAudio()
    }

    @IBAction func skipToNext(_ sender: AnyObject){
        AudioKit.ndAudioPlayer.skipTrack()
        AudioKit.ndAudioPlayer.playAudio()
        changeLabel()
        progressSlider?.setValue(0.0, animated: true)
    }
    
    @IBAction func skipToPrevious(_ sender: AnyObject){
        AudioKit.ndAudioPlayer.previousTrack()
        AudioKit.ndAudioPlayer.playAudio()
        changeLabel()
        progressSlider?.setValue(0.0, animated: true)
    }

    @IBAction func dismissPlayer(_ sender: AnyObject){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissBar"), object: nil)
        //tabBarController?.popupContentView.popupCloseButton.sendActions(for: .touchUpInside)
    }
    
    func changeLabel() {
        if (AudioKit.currentSongName != nil) {
            AudioKit.currentSongName = AudioKit.songList[AudioKit.ndAudioPlayer.getCurrentTrackIndex()]
        }
        
        var indexString: String = AudioKit.songList[AudioKit.ndAudioPlayer.getCurrentTrackIndex()]
        let url = NSURL(string: indexString)
        indexString = (url?.lastPathComponent)!
        indexString = AudioKit.downloadManager.removeExtension(fromFile: indexString)
    }
    
    // MARK: - Song Info Center
    @objc func putInformationInSongInfoCenter() {
        
        if AudioKit.songList.isEmpty == true {return}

        let isIndexValid = AudioKit.songList.indices.contains(AudioKit.ndAudioPlayer.getCurrentTrackIndex())
        if isIndexValid == false {return}
        
        
        if let url = URL(string: AudioKit.songList[AudioKit.ndAudioPlayer.getCurrentTrackIndex()]){
            var songName: String = (url.lastPathComponent)
            songName = songName.removingPercentEncoding!
            songName = AudioKit.downloadManager.removeExtension(fromFile: songName)
            
            guard let imageView = albumArtImageView else {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : albumTitle,  MPMediaItemPropertyTitle : songTitle, MPNowPlayingInfoPropertyElapsedPlaybackTime: AudioKit.currentTime, MPMediaItemPropertyPlaybackDuration: AudioKit.ndAudioPlayer.getTotalDuration()]
                return
            }
            
            guard let image: UIImage = imageView.image else {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : albumTitle,  MPMediaItemPropertyTitle : songTitle, MPNowPlayingInfoPropertyElapsedPlaybackTime: AudioKit.currentTime, MPMediaItemPropertyPlaybackDuration: AudioKit.ndAudioPlayer.getTotalDuration()]
                return
            }

            let albumArtwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                return image
            })
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : albumTitle,  MPMediaItemPropertyTitle : songTitle, MPNowPlayingInfoPropertyElapsedPlaybackTime: AudioKit.currentTime, MPMediaItemPropertyPlaybackDuration: AudioKit.ndAudioPlayer.getTotalDuration(), MPMediaItemPropertyArtwork: albumArtwork]
        }

    }
    
    @objc func downloadCompleted() {
        self.downloadButton?.setTitle("Saved", for: .normal)
        trackEvent(category: "Download", value: 1)
        downloadCompletedFunction()
    }
    
    func playSelectedSong(notification: NSNotification) {
        let userInformation: NSDictionary = notification.object as! NSDictionary
        var songName: String = userInformation.object(forKey: "songName") as! String
        let ext: String = AudioKit.downloadManager.getExtensionFromFile(songName)
        songName = AudioKit.downloadManager.removeExtension(fromFile: songName)
        let url: URL? = AudioKit.downloadManager.getDownloadedFile(withName: songName, andExtension: ext)
        if  AudioKit.ndAudioPlayer.isPlaying {self.pauseButtonAction(self)}
        
        guard let songUrl = url else {return}
        let urlString: String = songUrl.absoluteString
        AudioKit.songList = []
        AudioKit.songList.append(urlString)
        AudioKit.ndAudioPlayer.prepare(toPlay: NSMutableArray(array: AudioKit.songList), at: 0, atVolume: AudioKit.ndAudioPlayer.getAudioVolume())
        self.changeLabel()
    }
}


extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        // Need to use the MPVolumeView in order to change volume, but don't care about UI set so frame to .zero
        let volumeView = MPVolumeView(frame: .zero)
        // Search for the slider
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        // Update the slider value with the desired volume.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
//        // Optional - Remove the HUD
//        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
//            volumeView.alpha = 0.000001
//            window.addSubview(volumeView)
//        }
    }
}
