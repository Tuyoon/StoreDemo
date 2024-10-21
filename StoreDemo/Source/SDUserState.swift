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
    private let gameCenter: SDGameCenter
    private var database: SDCloudKitDatabaseProtocol {
        didSet {
            database.delegate = self
        }
    }
    
    init(gameCenter: SDGameCenter, database: SDCloudKitDatabaseProtocol) {
        self.gameCenter = gameCenter
        self.database = database
    }
    
    // MARK: - Coins
    
    /// Last coins amount before iCloud sync.
    @SDUserDefaulltsStoredValue(defaultValue: 0, key: "app-userState-coinsCount")
    private(set) var storedCoinsCount: Int
    
    /// Coins amount
    var coins: Int {
        get {
            return database.coins
        }
        set {
            storedCoinsCount = newValue
            database.updateCoins(newValue)
            notifyAboutCoinsChange()
        }
    }
    
    /// Add coins
    func addCoins(_ coins: Int) {
        self.coins = max(self.coins + coins, 0)
        database.updateCoins(self.coins)
    }
}

// MARK: - Private Methods

extension SDUserState {
    private func notifyAboutCoinsChange() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .UserStateCoinsChanged, object: self.coins)
        }
    }
}

// MARK: - SDCloudKitDatabaseDelegate

extension SDUserState: SDCloudKitDatabaseDelegate {
    func cloudKitDatabaseDidLoad(_ database: SDCloudKitDatabase) {
        if database.coins != storedCoinsCount {
            storedCoinsCount = database.coins
            notifyAboutCoinsChange()
        }
    }
    
    func cloudKitDatabase(_ database: SDCloudKitDatabase, didLoadCoins coins: Int) {
        gameCenter.submitCoins(coins)
    }
}
