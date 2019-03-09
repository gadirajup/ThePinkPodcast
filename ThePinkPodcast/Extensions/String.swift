//
//  String.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/8/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import Foundation

extension String {
    func toSecureHTTPS() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}
