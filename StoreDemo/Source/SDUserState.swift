//
//  UserState.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import Foundation

extension Notification.Name {
    static let UserStateCoinsChanged = Notification.Name("SDUserStatisticsCoinsChanged")
}

/// User State
class SDUserState {
    static let shared = SDUserState()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(userStateUpdatedNotification), name: .UserStateUpdated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UserStateUpdated, object: nil)
    }
    
    @objc
    private func userStateUpdatedNotification(_ notification: Notification) {
        if SDCloudKitDatabase.shared.coins != storedCoinsCount {
            storedCoinsCount = coins
            notifyAboutCoinsChange()
        }
    }
    
    // MARK: - Coins
    
    /// Last coins amount before iCloud sync.
    @SDUserDefaulltsStoredValue(defaultValue: 0, key: "app-userState-coinsCount")
    private(set) var storedCoinsCount: Int
    
    /// Coins amount
    var coins: Int {
        get {
            return SDCloudKitDatabase.shared.coins
        }
        set {
            storedCoinsCount = newValue
            SDCloudKitDatabase.shared.updateCoins(newValue)
            notifyAboutCoinsChange()
        }
    }
    
    /// Add coins
    func addCoins(_ coins: Int) {
        self.coins = max(self.coins + coins, 0)
        
        SDGameCenter.shared.submitCoins(self.coins)
    }
}

// MARK: - Private Methods

extension SDUserState {
    private func notifyAboutCoinsChange() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .UserStateCoinsChanged, object: nil)
        }
    }
    
}
