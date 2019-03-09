//
//  RSSFeed.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/8/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import Foundation
import FeedKit

extension RSSFeed {
    func toEpisodes() -> [Episode] {
        var episodes = [Episode]()
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }
            episodes.append(episode)
        })
        
        return episodes
    }
}
