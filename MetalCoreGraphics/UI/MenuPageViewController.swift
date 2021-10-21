//
//  MenuPageViewController.swift
//  PolyDraw
//
//  Created by Jason Smith on 12/18/18.
//  Copyright © 2018 Jason Smith. All rights reserved.
//

import UIKit

class MenuPageViewController: UIViewController {
    
    var pageView: MenuPageView! { return (self.view as! MenuPageView) }
    var contentView: UIView!
    var lastComponent: UIView?
    var lastConstraint: NSLayoutConstraint?
    
    override func loadView() {
        view = MenuPageView()
        setupContentView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        print("contentView.height = ", contentView.frame.size.height)
        
        
    }
    
    func setupContentView() {
        contentView = UIView()
//        contentView.backgroundColor = UIColor(white: 0.1, alpha: UIConstants.menuBackgroundOpacity)
//        contentView.backgroundColor = .gray
//        contentView.layer.cornerRadius = UIConstants.menuButtonCornerRadius
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        contentView.pinEdges(toView: view)
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        let heightConstraint = contentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
        
    }
    
    func show() {
        view.isHidden = false
    }
    
    func hide() {
        view.isHidden = true
    }
    
    func addComponent(_ component: UIView, withSpacing spacing: CGFloat = 20) {
        contentView.addSubview(component)
        component.translatesAutoresizingMaskIntoConstraints = false
        component.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.menuPageMargin).isActive = true
        component.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.menuPageMargin).isActive = true
        
        if let lastComponent = lastComponent {
            component.topAnchor.constraint(equalTo: lastComponent.bottomAnchor, constant: spacing).isActive = true
            
//            if let lastConstraint = lastConstraint {
//                lastComponent.removeConstraint(lastConstraint)
//
//                self.lastConstraint = component.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.menuPageMargin)
//                self.lastConstraint!.isActive = true
//                self.lastConstraint!.priority = .defaultLow
//
//            }
            
        } else {
            component.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.menuPageMargin).isActive = true
            
//            self.lastConstraint = component.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.menuPageMargin)
//            self.lastConstraint!.isActive = true
//            self.lastConstraint!.priority = .defaultLow
        }
        lastComponent = component
        
        
        
    }
    
    func constrainLastComponent() {
        if let lastComponent = lastComponent {
            
            let constraint = lastComponent.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -UIConstants.menuPageMargin)
            
//            let constraint = lastComponent.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.menuPageMargin)
            
            constraint.priority = UILayoutPriority(500)
            constraint.isActive = true
            
        }
    }
    
}
