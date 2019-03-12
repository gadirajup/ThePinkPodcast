//
//  Podcast.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/8/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import Foundation

class Podcast: Encodable, Decodable {    
    var trackName: String?
    var artistName: String?
    var trackCount: Int?
    var artworkUrl600: String?
    var feedUrl: String?
}
