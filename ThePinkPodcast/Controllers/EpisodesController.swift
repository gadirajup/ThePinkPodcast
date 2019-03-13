//
//  EpisodesController.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/8/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    
    var episodes = [Episode]()
    
    fileprivate let cellId = "cellId"
    
    var podcast: Podcast? {
        didSet {
            fetchEpisodes()
            navigationItem.title = podcast?.trackName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBarButtons()
        setupTableView()
    }
    
    fileprivate func setupNavBarButtons() {
        
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        
        let hasFavorited = savedPodcasts.contains(where: {
            $0.trackName == self.podcast?.trackName
        })
        
        if hasFavorited {
            var image = #imageLiteral(resourceName: "heart")
            image = image.withRenderingMode(.alwaysOriginal)
            
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: nil)
            ]
        } else {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
                //UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcasts))
            ]
        }
    }
    
    @objc fileprivate func handleSaveFavorite() {
        guard let podcast = podcast else {
            print("Podcast != Podcast")
            return
        }
        UserDefaults.standard.savePodcast(podcast: podcast)
        showBadgeHighlight()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: nil)
    }
    
    fileprivate func showBadgeHighlight() {
        UIApplication.mainTabBarController()?.viewControllers?[0].tabBarItem.badgeValue = "New"
    }
    
    @objc fileprivate func handleFetchSavedPodcasts() {
        
        print("fetch began")
        
        let podcasts = UserDefaults.standard.savedPodcasts()
        podcasts.forEach { (p) in
            print(p.trackName ?? "")
        }
    }
    
    func fetchEpisodes() {
        guard let feedUrl = podcast?.feedUrl else {return}
        
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // Mark:- Setup Functions
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    // MARK:- Table View Functions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = episodes[indexPath.row]
        
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        
        mainTabBarController?.maximizePlayerDetailsView(withEpisode: episode, playlistEpisodes: self.episodes)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            UserDefaults.standard.downloadEpisode(episode: self.episodes[indexPath.row])
            UIApplication.mainTabBarController()?.viewControllers?[2].tabBarItem.badgeValue = "New"
            
            // Download with Alamofire
            APIService.shared.downloadEpisode(episode: self.episodes[indexPath.row])
        }
        
        return [downloadAction]
    }
}
