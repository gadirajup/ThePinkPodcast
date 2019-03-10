//
//  PlayerDetailsView.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/8/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import UIKit
import AVKit

class PlayerDetailsView: UIView {
    
    var panGesture: UIPanGestureRecognizer!
    var episode: Episode! {
        didSet {
            episodeTitle.text = episode.title
            miniTitleLabel.text = episode.title
            
            authorLabel.text = episode.author
            
            playEpisode()
            
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            episodeImageView.sd_setImage(with: url)
            miniEpisodeImageView.sd_setImage(with: url)
        }
    }
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
        
        setupGestures()
        observePlayerCurrentTime()
        setupTimeObserver()
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
        guard let url = URL(string: episode.streamUrl) else {return}
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
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
