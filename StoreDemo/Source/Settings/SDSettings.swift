//
//  SDSettings.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

class SDSettings {
    // MARK: - UI
    /// Background color.
    @SDUserDefaulltsStoredValue(defaultValue: SDColor.defaultBackgroundColor, key: "settings-backgroundColor")
    static var backgroundColor: UIColor
}
