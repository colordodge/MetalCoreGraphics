//
//  BaseSlider.swift
//  PolyDraw
//
//  Created by Jason Smith on 12/18/18.
//  Copyright © 2018 Jason Smith. All rights reserved.
//

import Foundation
import UIKit

class BaseSlider: UISlider {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds: CGRect = self.bounds
        bounds = bounds.insetBy(dx: -20, dy: -20)
        return bounds.contains(point)
    }
    
}
