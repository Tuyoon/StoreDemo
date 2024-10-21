//
//  SDUserDefaulltsStoredValue.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

/// UserDefaults key-value storage.
@propertyWrapper
class SDUserDefaulltsStoredValue<Value> {
    
    var wrappedValue: Value {
        get {
            if Value.self == UIColor.self {
                if let colorComponents = storage.array(forKey: key) as? [CGFloat] {
                    let cgColor = CGColor(red: colorComponents[0],
                                          green: colorComponents[1],
                                          blue: colorComponents[2],
                                          alpha: colorComponents[3])
                    return UIColor(cgColor: cgColor) as! Value
                }
                return value
            }
            return storage.object(forKey: key) as? Value ?? value
        }
        set {
            if let color = newValue as? UIColor, let colorComponents = color.cgColor.components {
                storage.setValue(colorComponents, forKey: key)
                return
            }
            storage.set(newValue, forKey: key)
        }
    }
    
    private let storage: UserDefaults
    private var value: Value
    private let key: String
    
    /// Inits codable UserDefaultsStorageValue property
    /// - Parameters:
    ///  - defaultValue: Default value of the property if there was no value before
    ///  - key: Key under which the values is stored
    ///  - storage: UserDefaults suit in which the value is store. By default, it is .standard
    init(defaultValue: Value, key: String, storage: UserDefaults = .standard) {
        self.storage = storage
        self.value = storage.object(forKey: key) as? Value ?? defaultValue
        self.key = key
    }
}
