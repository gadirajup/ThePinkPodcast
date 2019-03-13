//
//  MainTabBarController.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/8/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let playerDetailsView = PlayerDetailsView.initFromNib()
    var maxTopAnchorConstraint: NSLayoutConstraint!
    var minTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarController()
        setupViewControllers()
        setupPlayerDetailsView()
    }
    
    @objc func minimizePlayerDetails() {
        
        maxTopAnchorConstraint.isActive = false
        minTopAnchorConstraint.isActive = true
        minTopAnchorConstraint.constant = -64
        bottomAnchorConstraint.constant = view.frame.height
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
            self.playerDetailsView.maximizedStackView.alpha = 0
            self.playerDetailsView.minimizedView.alpha = 1
        }, completion: nil)
    }
    
    func maximizePlayerDetailsView(withEpisode episode: Episode?, playlistEpisodes: [Episode] = []) {
        
        if episode != nil {
            playerDetailsView.episode = episode
        }
        
        playerDetailsView.playListEpisodes = playlistEpisodes
        
        minTopAnchorConstraint.isActive = false
        maxTopAnchorConstraint.isActive = true
        maxTopAnchorConstraint.constant = 44
        bottomAnchorConstraint.constant = 0
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.playerDetailsView.maximizedStackView.alpha = 1
            self.playerDetailsView.minimizedView.alpha = 0
        }, completion: nil)
    }
    
    // MARK:- Setup Functions
    
    fileprivate func setupTabBarController() {
        tabBar.tintColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
    }
    
    fileprivate func setupViewControllers() {
        viewControllers = [
            generateNavigationController(with: FavoritesController(collectionViewLayout: UICollectionViewFlowLayout()), title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationController(with: PodcastSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationController(with: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }
    
    fileprivate func setupPlayerDetailsView() {
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        
        playerDetailsView.layer.cornerRadius = 14
        playerDetailsView.layer.shadowColor = UIColor.lightGray.cgColor
        playerDetailsView.layer.shadowOffset = CGSize(width: 0, height: -5)
        playerDetailsView.layer.shadowRadius = 5
        playerDetailsView.layer.shadowOpacity = 0.5
        
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        maxTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maxTopAnchorConstraint.isActive = false
        
        minTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: 64)
        minTopAnchorConstraint.isActive = true

        bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomAnchorConstraint.isActive = true
        
        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    // MARK:- Helper Functions
    
    fileprivate func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        rootViewController.navigationItem.title = title
        
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.navigationBar.prefersLargeTitles = true
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        
        return navController
    }
}
