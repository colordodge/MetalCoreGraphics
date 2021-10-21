//
//  UIView+Layout.swift
//  PolyDraw
//
//  Created by Jason Smith on 12/18/18.
//  Copyright © 2018 Jason Smith. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func pinLeading(toView view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant).isActive = true
    }
    
    func pinTrailing(toView view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant).isActive = true
    }
    
    func pinTopToTop(toView view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor, constant: constant).isActive = true
    }
    
    func pinTopToBottom(toView view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.bottomAnchor, constant: constant).isActive = true
    }
    
    func pinBottom(toView view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant).isActive = true
    }
    
    func pinSides(toView view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -constant)
            ])
    }
    
    func pinCenterX(toView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func pinCenterY(toView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func pinEdges(toView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    func pinSize(toView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1)
            ])
    }
    
    func pinWidth(toView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1)
            ])
    }
    
    func pinHeight(toValue value: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: value)
            ])
    }
    
    func pinWidth(toValue value: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: value)
            ])
    }
}
