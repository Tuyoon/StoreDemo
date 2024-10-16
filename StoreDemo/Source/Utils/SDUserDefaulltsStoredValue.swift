//
//  SDUserDefaulltsStoredValue.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import Foundation

/// UserDefaults key-value storage.
@propertyWrapper
class SDUserDefaulltsStoredValue<Value> {
    
    var wrappedValue: Value {
        get {
            return storage.object(forKey: key) as? Value ?? value
        }
        set {
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
