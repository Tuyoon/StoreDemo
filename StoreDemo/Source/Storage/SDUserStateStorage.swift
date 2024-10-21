//
//  SDUserStateStorage.swift
//  StoreDemo
//
//  Created by Admin on 21.10.2024.
//

import Foundation

protocol SDUserStateStorageProtocol {
    var coins: Int { get }
    func updateCoins(_ coins: Int)
}
