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
        
        setupTableView()
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
}
