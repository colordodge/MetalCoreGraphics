//
//  Slider.swift
//  PolyDraw
//
//  Created by Jason Smith on 12/18/18.
//  Copyright © 2018 Jason Smith. All rights reserved.
//

import UIKit

class Slider: UIView {
    
    let innerSpacing = CGFloat(6)
    var min = 0.0
    var max = 1.0
    var value = 0.5
    var isInt = false
    var title = "Title"
    var isRestricted: Bool
    var titleLabel: UILabel!
    var valueLabel: UILabel!
    var slider: BaseSlider!
    var unlockedConstraint: NSLayoutConstraint!
    var longPress: UILongPressGestureRecognizer!
    var tap: UITapGestureRecognizer!
    
    var onChange: ((Double) -> ())?
    
    init(title: String, min: Double, max: Double, value: Double, isInt: Bool, isRestricted: Bool = false) {
        self.isRestricted = isRestricted
        super.init(frame: .zero)
        self.min = min
        self.max = max
        self.isInt = isInt
        self.title = title
        self.value = value
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        setup()
        setValue(value)
        
        
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        longPress.minimumPressDuration = 0.01
        longPress.delegate = self

    }
    
    func setup() {
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        /// title label
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.font = Fonts.basic
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.text = title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        
        unlockedConstraint = titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        
        /// value label
        valueLabel = UILabel()
        addSubview(valueLabel)
        valueLabel.font = Fonts.basic
        valueLabel.textColor = .white
        valueLabel.textAlignment = .right
        valueLabel.text = "0.0"
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        
        /// slider
        slider = BaseSlider()
        addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        let thumbImage = getSliderImage()
        slider.setThumbImage(thumbImage, for: .normal)
        slider.setThumbImage(thumbImage, for: .highlighted)
        slider.minimumTrackTintColor = UIColor(white: 1, alpha: 0.5)
        slider.maximumTrackTintColor = UIColor(white: 1, alpha: 0.5)
        slider.minimumValue = 0
        slider.maximumValue = 1
        
        slider.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        slider.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: innerSpacing).isActive = true
//        slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        slider.addTarget(self, action: #selector(onSliderChange(_:event:)), for: .valueChanged)
        
    }
    
    @objc func onSliderChange(_ slider: UISlider, event: UIEvent) {
        
        updateValueLabel()
        onChange?(value)

    }
    
    @objc func onLongPress() {
        /// block touches
    }
    
    func updateValueLabel() {
        let ratio = Double(slider.value / 1.0)
        let range = max - min
        value = min + range * ratio
        
        if (isInt) {
            let roundedValue = Int(round(value))
            valueLabel.text = String(roundedValue)
        } else {
            let roundedValue = Double(round(100*value)/100)
            valueLabel.text = String(roundedValue)
        }
    }
    
    func setValue(_ value: Double) {
        let range = max - min
        let ratio = (value-min) / range
        self.slider.setValue(Float(ratio), animated: true)
        updateValueLabel()
    }
    
    func getSliderImage() -> UIImage? {
        
        let size = CGFloat(20)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }

}

extension Slider: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
