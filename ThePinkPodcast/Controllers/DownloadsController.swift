//
//  DownloadsControlle.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/13/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import Foundation
import UIKit

class DownloadsController: UITableViewController {
    
    fileprivate let cellId = "CellId"
    
    var episodes = UserDefaults.standard.fetchDownloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupObservers()
        UIApplication.mainTabBarController()?.viewControllers?[2].tabBarItem.badgeValue = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        episodes = UserDefaults.standard.fetchDownloadedEpisodes()
        tableView.reloadData()
    }
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: NotificationCenter.name, object: nil)
    }
    
    @objc func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else {return}
        
        guard let progress = userInfo["progress"] as? Double else {return}
        guard let title = userInfo["title"] as? String else {return}
        
        guard let index = episodes.firstIndex(where: {$0.title == title}) else {return}
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else {return}
        
        cell.progressLabel.isHidden = false

        
        cell.progressLabel.text = "\(Int(progress * 100))%"
        
        if progress == 1 {
            cell.progressLabel.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.episode = episodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            UserDefaults.standard.removeEpisode(episode: self.episodes[indexPath.row])
            self.episodes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        }
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.mainTabBarController()?.maximizePlayerDetailsView(withEpisode: episodes[indexPath.row], playlistEpisodes: episodes)
    }
}
