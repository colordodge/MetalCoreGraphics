//
//  MenuButton.swift
//  PolyDraw
//
//  Created by Jason Smith on 12/14/18.
//  Copyright © 2018 Jason Smith. All rights reserved.
//

import UIKit

class MenuButton: UIButton, UIGestureRecognizerDelegate {
    
    var whiteIcon: UIImage!
    var blackIcon: UIImage!
    
    var tapAction: () -> Void = {}
    
    override open var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .white
                imageView?.layer.shadowOpacity = 0.0
            } else {
                backgroundColor = UIConstants.menuPageBackgroundColor
                imageView?.layer.shadowOpacity = 0.5
            }
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = .white
                imageView?.layer.shadowOpacity = 0.0
            } else {
                if !isSelected {
                    backgroundColor = UIConstants.menuPageBackgroundColor
                    imageView?.layer.shadowOpacity = 0.5
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(withAsset asset: Asset) {
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIConstants.menuPageBackgroundColor
        adjustsImageWhenHighlighted = false
        
        whiteIcon = UIImage(named: asset.rawValue)!
        blackIcon = whiteIcon.invertedImage()
        setImage(whiteIcon, for: .normal)
        setImage(blackIcon, for: .selected)
        setImage(blackIcon, for: .highlighted)
        
        layer.cornerRadius = UIConstants.menuButtonCornerRadius
        
        imageView?.layer.shadowColor = UIColor.black.cgColor
        imageView?.layer.shadowOpacity = 0.5
        imageView?.layer.shadowOffset = CGSize.zero
        imageView?.layer.shadowRadius = 2
        imageView?.clipsToBounds = false
    }
    
    override func didMoveToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = widthAnchor.constraint(equalToConstant: UIConstants.menuButtonWidth)
        widthConstraint.isActive = true
        let heightConstraint = heightAnchor.constraint(equalToConstant: UIConstants.menuButtonHeight)
        heightConstraint.isActive = true
        
        widthConstraint.priority = .required
        heightConstraint.priority = .required
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
        tap.delegate = self
    }
    
    @objc private func onTap(_ gesture: UITapGestureRecognizer) {
        tapAction()
    }
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
