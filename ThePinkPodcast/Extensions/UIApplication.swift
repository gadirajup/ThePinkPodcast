//
//  UIApplication.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/9/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
