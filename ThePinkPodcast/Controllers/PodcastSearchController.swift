//
//  PodcastSearchController.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/8/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import UIKit
import Alamofire

class PodcastSearchController: UITableViewController, UISearchBarDelegate {
    
    let cellId = "cellId"
    let searchController = UISearchController(searchResultsController: nil)
    let podcasts = [
        Podcast(name: "Startup Lyfe", artistName: "Prudhvi Gadiraju"),
        Podcast(name: "Pink Panther Trials", artistName: "Prudhvi Gadiraju"),
        Podcast(name: "Holla Holla", artistName: "Prudhvi Gadiraju")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
    }
    
    // MARK:- Setup Functions
    fileprivate func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    fileprivate func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    // MARK:- Search Functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Add AlamoFire
        let url = "https://itunes.apple.com/search?term=\(searchText)"
        Alamofire.request(url).response { (dataResponse) in
            if let error = dataResponse.error {
                print("Failed to contact Yahoo", error)
                return
            }

            guard let data = dataResponse.data else {return}
            let dummyString = String(data: data, encoding: .utf8)
            print(dummyString ?? "")
        }
    }
    
    
    // MARK:- Table View Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let podcast = self.podcasts[indexPath.row]
        cell.textLabel?.text = podcast.name
        cell.textLabel?.numberOfLines = -1
        cell.detailTextLabel?.text = podcast.artistName
        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        return cell
    }
}
