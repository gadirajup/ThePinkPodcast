//
//  Episode.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/8/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
    let title: String
    let pubDate: Date
    let description: String
    var imageUrl: String?
    
    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.description ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
    }
}

