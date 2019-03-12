//
//  UserDefaults.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/11/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favoritedPodcastsKey = "favoritedPodcastsKey"

    func savedPodcasts() -> [Podcast] {
        do{
            if let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastsKey){
                let podcasts = try JSONDecoder().decode([Podcast].self, from: data)
                return podcasts
            }
        }catch let error {
            print("Failed to get Saved Podcasts: Error: \(error)")
        }
        
        return []
    }
    
    func savePodcast(podcast: Podcast) {
        do {
            var podcasts = [Podcast]()
            
            if let currentPodcastData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastsKey) {
                podcasts = try JSONDecoder().decode([Podcast].self, from: currentPodcastData)
            }
            
            podcasts.append(podcast)
            
            let newPodcastData = try JSONEncoder().encode(podcasts)
            UserDefaults.standard.set(newPodcastData, forKey: UserDefaults.favoritedPodcastsKey)
            print("success")
            
        }catch let error {
            print("Failed to save: Error: \(error)")
        }
    }
    
    func removePodcast(podcast: Podcast) {
        do {
            var newPodcasts = [Podcast]()
            
            if let currentPodcastData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastsKey) {
                let podcasts = try JSONDecoder().decode([Podcast].self, from: currentPodcastData)
                newPodcasts = podcasts.filter { (p) -> Bool in
                    p.trackName != podcast.trackName
                }
            }
            
            let newPodcastData = try JSONEncoder().encode(newPodcasts)
            UserDefaults.standard.set(newPodcastData, forKey: UserDefaults.favoritedPodcastsKey)
            print("success")
            
        }catch let error {
            print("Failed to save: Error: \(error)")
        }
    }
}
