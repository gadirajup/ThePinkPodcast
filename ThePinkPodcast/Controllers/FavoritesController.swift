//
//  FavoritesController.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/11/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import Foundation
import UIKit

class FavoritesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "CellId"
    var podcasts = UserDefaults.standard.savedPodcasts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        podcasts = UserDefaults.standard.savedPodcasts()
        collectionView.reloadData()
        
        UIApplication.mainTabBarController()?.viewControllers?[0].tabBarItem.badgeValue = nil
    }
    
    //MARK:- Setup Functions
    
    fileprivate func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress)))
    }
    
    //MARK:- Handle Functions
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {return}
        
        let alert = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (_) in
            UserDefaults.standard.removePodcast(podcast: self.podcasts[indexPath.row])
            self.podcasts.remove(at: indexPath.row)
            self.collectionView.deleteItems(at: [indexPath])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    //MARK:- CollectionView Functions
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavoritePodcastCell
        cell.podcast = podcasts[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episodesController = EpisodesController()
        episodesController.podcast = self.podcasts[indexPath.row]
        
        navigationController?.pushViewController(episodesController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3 * 16) / 2
        return CGSize(width: width, height: width + 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
