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
    static let downloadedEpisodesKey = "downloadedEpisodesKey"

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
    
    func downloadEpisode(episode: Episode) {
        do {
            var downloadedEpisodes = fetchDownloadedEpisodes()
            downloadedEpisodes.insert(episode, at: 0)
            
            let data = try JSONEncoder().encode(downloadedEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchDownloadedEpisodes() -> [Episode] {
        do {
            if let data = UserDefaults.standard.data(forKey: UserDefaults.downloadedEpisodesKey) {
                let episodesArray = try JSONDecoder().decode([Episode].self, from: data)
                return episodesArray
            }
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    func removeEpisode(episode: Episode) {
        do {
            let newEpisodes = fetchDownloadedEpisodes()
            let filteredEpisodes = newEpisodes.filter({return $0.streamUrl != episode.streamUrl})
            
            let newEpisodeData = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(newEpisodeData, forKey: UserDefaults.downloadedEpisodesKey)
        }catch let error {
            print("Failed to save: Error: \(error)")
        }
    }
    
    func updateDownloadedEpisodes(withEpisodes episodes: [Episode]) {
        do {
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch {
            print(error.localizedDescription)
        }
    }
}
