//
//  Asset.swift
//  PolyDraw
//
//  Created by Jason Smith on 12/14/18.
//  Copyright © 2018 Jason Smith. All rights reserved.
//

import Foundation
import UIKit

enum Asset: String {
    case menuIcon = "menuIcon"
    
    func uiImage() -> UIImage {
        return UIImage(named: self.rawValue)!
    }
}
