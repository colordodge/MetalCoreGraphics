//
//  MenuPageView.swift
//  PolyDraw
//
//  Created by Jason Smith on 12/18/18.
//  Copyright © 2018 Jason Smith. All rights reserved.
//

import UIKit

class MenuPageView: UIScrollView {

    override func didMoveToSuperview() {
//        if let parentView = superview {
//            pinEdges(toView: parentView)
//        }
        
        backgroundColor = UIConstants.menuPageBackgroundColor
        clipsToBounds = true
        layer.cornerRadius = UIConstants.menuButtonCornerRadius
        
        Events.listen(.configUpdated, #selector(updateUI), self)
        
    }
    
    @objc func updateUI() {
        backgroundColor = UIConstants.menuPageBackgroundColor
    }

}
