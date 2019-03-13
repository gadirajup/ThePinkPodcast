//
//  PlayerDetailsView.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/8/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
    
    var panGesture: UIPanGestureRecognizer!
    var episode: Episode! {
        didSet {
            episodeTitle.text = episode.title
            miniTitleLabel.text = episode.title
            authorLabel.text = episode.author
            
            setupNowPlayingInfo()
            setupAudioSession()
            playEpisode()
            
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            episodeImageView.sd_setImage(with: url)
            miniEpisodeImageView.sd_setImage(with: url)
            miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
                guard let image = image else {return}
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
                let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
                    return image
                })
                nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
    var playListEpisodes = [Episode]()
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()

    
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var maximizedStackView: UIStackView!
    @IBOutlet weak var minimizedView: UIView!
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    
    @IBOutlet weak var miniPlayButton: UIButton! {
        didSet {
            miniPlayButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            episodeImageView.layer.cornerRadius = 8
            episodeImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var miniFastForwardButton: UIButton! {
        didSet {
            miniFastForwardButton.addTarget(self, action: #selector(handleFastForward(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
            playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupRemoteControl()
        setupGestures()
        observePlayerCurrentTime()
        setupTimeObserver()
        setupInterruptionObserver()
    }
    
    fileprivate func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else {return}
        
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else {
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {return}
            
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                player.play()
                playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                miniPlayButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
    }
    
    fileprivate func setupNowPlayingInfo() {
        var nowPlayingInfo = [String:Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func setupLockScreenCurrentTime() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        
        guard let currentItem = player.currentItem else {return}
        let durationInSeconds = CMTimeGetSeconds(currentItem.duration)
        let elaspedTime = CMTimeGetSeconds(player.currentTime())
        
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elaspedTime
        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func setupRemoteControl() {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
            return MPRemoteCommandHandlerStatus.success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
            return MPRemoteCommandHandlerStatus.success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
        
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))

    }
    
    @objc func handlePreviousTrack() {
        if playListEpisodes.count == 0 {
            return
        }
        
        let currentEpisodeIndex = playListEpisodes.firstIndex { (ep) -> Bool in
            return self.episode.title == ep.title
        }
        
        guard let index = currentEpisodeIndex else {return}
        let nextEpisode: Episode
        
        if index == 0 {
            nextEpisode = playListEpisodes[playListEpisodes.count-1]
        } else {
            nextEpisode = playListEpisodes[index-1]
        }
        
        self.episode = nextEpisode
    }
    
    
    @objc func handleNextTrack() {
        if playListEpisodes.count == 0 {
            return
        }
        
        let currentEpisodeIndex = playListEpisodes.firstIndex { (ep) -> Bool in
            return self.episode.title == ep.title
        }
        
        guard let index = currentEpisodeIndex else {return}
        let nextEpisode: Episode
        
        if index == playListEpisodes.count-1 {
            nextEpisode = playListEpisodes[0]
        } else {
            nextEpisode = playListEpisodes[index+1]
        }
        
        self.episode = nextEpisode
    }
    
    fileprivate func setupAudioSession(){
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate session", error.localizedDescription)
        }
    }
    
    fileprivate func setupTimeObserver() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeImageView()
        }
    }
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTime(seconds: 1, preferredTimescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()
            
            self?.setupLockScreenCurrentTime()
            
            self?.updateCurrentTimeSlider()
        }
    }
    
    func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds/durationSeconds
        
        currentTimeSlider.value = Float(percentage)
    }
    
    
    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            let translation = gesture.translation(in: self.superview)
            self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: self.superview)

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.transform = .identity

                if translation.y > 200 {
                    let mainTabBarController = UIApplication.mainTabBarController()
                    mainTabBarController?.minimizePlayerDetails()
                }
                
            }, completion: nil)
        }
    }
    
    fileprivate func handlPanEnded(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.transform = .identity
            
            if translation.y < -200 || velocity.y < -500 {
                let mainTabBarController = UIApplication.mainTabBarController()
                mainTabBarController?.maximizePlayerDetailsView(withEpisode: nil)
            } else {
                self.minimizedView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
            
        }, completion: nil)
    }
    
    fileprivate func handlePanChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        self.minimizedView.alpha = 1 + translation.y / 200
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            handlePanChanged(gesture)
        } else if gesture.state == .ended {
            handlPanEnded(gesture)
        }
    }
    
    @objc func handleTapMaximize() {
        let mainTabBarController = UIApplication.mainTabBarController()
        mainTabBarController?.maximizePlayerDetailsView(withEpisode: nil)
    }
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    fileprivate func playEpisode() {
        if episode.fileUrl != nil {
            
            guard let fileURL = URL(string: episode.fileUrl ?? "") else {return}
            let fileName = fileURL.lastPathComponent
            guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
            trueLocation.appendPathComponent(fileName)
            
            let playerItem = AVPlayerItem(url: trueLocation)
            player.replaceCurrentItem(with: playerItem)
            player.play()
        } else {
            guard let url = URL(string: episode.streamUrl) else {return}
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.play()
        }
        
        playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    @objc func handlePlayPause() {
        if player.timeControlStatus == .paused {
            player.play()
            enlargeImageView()
            playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            player.pause()
            shrinkImageView()
            playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    
    fileprivate func enlargeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        }, completion: nil)
    }
    
    fileprivate func shrinkImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: nil)
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage)*durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleRewind(_ sender: Any) {
        let fifteenSeconds = CMTimeMakeWithSeconds(15, preferredTimescale: 1)
        let seekTime = CMTimeSubtract(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleFastForward(_ sender: Any) {
        let fifteenSeconds = CMTimeMakeWithSeconds(15, preferredTimescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    @IBAction func handleDismiss(_ sender: Any) {
        let mainTabBarController = UIApplication.mainTabBarController()
        mainTabBarController?.minimizePlayerDetails()
    }
}
