//
//  SDUserStateStorageContainer.swift
//  StoreDemo
//
//  Created by Admin on 21.10.2024.
//

import Foundation

class SDUserStateStorageContainer: SDUserStateStorageProtocol {
    private(set) var coins: Int = 0
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
    
    func updateCoins(_ coins: Int) {
        database.updateCoins(coins)
    }
}

extension SDUserStateStorageContainer: SDCloudKitDatabaseDelegate {
    func cloudKitDatabaseDidLoad(_ database: SDCloudKitDatabase) {
        
    }
    
    func cloudKitDatabase(_ database: SDCloudKitDatabase, didLoadCoins coins: Int) {
        gameCenter.submitCoins(coins)
    }
}
