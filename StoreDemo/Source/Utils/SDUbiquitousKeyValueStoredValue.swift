//
//  UbiquitousKeyValueStoredValue.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import Foundation

/// iCloud key-value storage
@propertyWrapper
class SDUbiquitousKeyValueStoredValue<Value> {
    
    var wrappedValue: Value {
        get {
            storage.synchronize()
            return storage.object(forKey: key) as? Value ?? value
        }
        set {
            defer {
                storage.synchronize()
            }
            storage.set(newValue, forKey: key)
        }
    }
    
    private let storage: NSUbiquitousKeyValueStore
    private var value: Value
    private let key: String
    
    /// Inits codable iCloud key-value stored property
    /// - Parameter defaultValue: Default value of the property if there was no value before
    /// - Parameter key: Key under which the values is stored
    /// - Parameter storage: NSUbiquitousKeyValueStore suit in which the value is store.
    init(defaultValue: Value, key: String, storage: NSUbiquitousKeyValueStore = .default) {
        self.storage = storage
        self.value = storage.object(forKey: key) as? Value ?? defaultValue
        self.key = key
    }
}
