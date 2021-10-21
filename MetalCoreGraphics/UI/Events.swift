//
//  Events.swift
//  PolyDraw
//
//  Created by Jason Smith on 12/14/18.
//  Copyright © 2018 Jason Smith. All rights reserved.
//

import Foundation

enum EventType: String {
    case configUpdated = "configUpdated"
    case pauseWasToggled = "pauseWasToggled"
    case pauseButtonWasTapped = "pauseButtonWasTapped"
    case screenRotated = "screenRotated"
    case colorSelectorExpanded = "colorSelectorExpanded"
    case colorPaletteUpdated = "colorPaletteUpdated"
    case colorWasEdited = "colorWasEdited"
    case colorPaletteWasRandomized = "colorPaletteWasRandomized"
    case colorPaletteWasCleared = "colorPaletteWasCleared"
    case colorPaletteWasLoaded = "colorPaletteWasLoaded"
    case clearDocument = "clearDocument"
    case undoManagerDidStep = "undoManagerDidStep"
    case thumbnailWasSaved = "thumbnailWasSaved"
    case documentWasLoaded = "documentWasLoaded"
    case backgroundColorChipWasTapped = "background`ColorChipWasTapped"
    case upgradeStatusChanged = "upgradeStatusChanged"
    case lineDidEnd = "lineDidEnd"
    case touchStart = "touchStart"
    case didRestoreUpgrades = "didRestoreUpgrades"
    
    var notification : Notification.Name  {
        return Notification.Name(rawValue: self.rawValue )
    }
}

class Events {
    
    static func post(_ event: EventType) {
        NotificationCenter.default.post(name: event.notification, object: nil)
    }
    
    static func post(_ event: EventType, object: Any) {
        NotificationCenter.default.post(name: event.notification, object: object)
    }
    
    static func listen(_ event: EventType, _ selector: Selector, _ observer: AnyObject) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: event.notification, object: nil)
    }
    
    static func stopListening(_ observer: AnyObject) {
        NotificationCenter.default.removeObserver(observer)
    }
    
}
