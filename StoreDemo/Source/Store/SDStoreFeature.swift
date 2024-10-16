//
//  StoreFeature.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

enum SDStoreFeature: CaseIterable {
    case onlineGame
    case unlimitedEnergy
    case noAds
    case gamesHistory
    case colorStyles
    
    var title: String {
        switch self {
            case .onlineGame:
                return .PremiumStoreFeatureOnlineGame
            case .unlimitedEnergy:
                return .PremiumStoreFeatureUnlimitedGames
            case .noAds:
                return .PremiumStoreFeatureNoAds
            case .gamesHistory:
                return .PremiumStoreFeatureGamesHistory
            case .colorStyles:
                return .PremiumStoreFeatureColorStyles
        }
    }
    
    var image: UIImage {
        switch self {
            case .onlineGame:
                return UIImage(systemName: "person.3")!
            case .unlimitedEnergy:
                return UIImage(systemName: "infinity")!
            case .noAds:
                return UIImage(systemName: "video.slash")!
            case .gamesHistory:
                return UIImage(systemName: "book")!
            case .colorStyles:
                return UIImage(systemName: "paintpalette")!
        }
    }
}
