//
//  Podcast.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/8/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import Foundation

struct Podcast: Decodable {
    let trackName: String?
    let artistName: String?
    let trackCount: Int?
    let artworkUrl600: String?
    let feedUrl: String?
}
