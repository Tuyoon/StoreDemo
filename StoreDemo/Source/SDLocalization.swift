//
//  SDLocalization.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import Foundation

// MARK: - Rewards
extension String {
    static let RewardDailyInfo = NSLocalizedString("Reward.Daily.Info", comment: "Select daily reward")
    
    static let PushNotificationDailyRewardAvailableTitle = NSLocalizedString("Reward.Daily.Available.PushNotification.Title", comment: "Hoora")
    static let PushNotificationDailyRewardAvailableMessage = NSLocalizedString("Reward.Daily.Available.PushNotification.Message", comment: "Your daily reward is available now. Come to collect")
    
    static let RewardCoinsInfo = NSLocalizedString("Reward.Coins.Info", comment: "Get reward")
}

// MARK: - Store Premium

extension String {
    static let PremiumStoreTitle = NSLocalizedString("Store.Premium.Title", comment: "Unlock premium")
    static let PremiumStoreDescription = NSLocalizedString("Store.Premium.Description", comment: "Get all features")
    
    static let PremiumStoreSubscriptionActiveFormat = NSLocalizedString("Store.Premium.Subscription.ActiveFormat", comment: "Your subscription now active. Expires %@")
    static let PremiumStoreSubscriptionExpiredFormat = NSLocalizedString("Store.Premium.Subscription.ExpiredFormat", comment: "Your subscription expired %@")
    
    static let PremiumStoreFeatureOnlineGame = NSLocalizedString("Store.Premium.Feature.OnlineGame", comment: "Online game")
    static let PremiumStoreFeatureUnlimitedGames = NSLocalizedString("Store.Premium.Feature.UnlimitedGames", comment: "Unlimited games")
    static let PremiumStoreFeatureNoAds = NSLocalizedString("Store.Premium.Feature.NoAds", comment: "No ads")
    static let PremiumStoreFeatureGamesHistory = NSLocalizedString("Store.Premium.Feature.GamesHistory", comment: "Games history")
    static let PremiumStoreFeatureColorStyles = NSLocalizedString("Store.Premium.Feature.ColorStyles", comment: "Color styles")
    
    static let StorePurchase = NSLocalizedString("Store.Purchase", comment: "Purchase")
    static let StoreRestore = NSLocalizedString("Store.Restore", comment: "Restore purchases")
    static let StoreRedeem = NSLocalizedString("Store.Redeem", comment: "Redeem offer code")
    static let StoreSubscriptionsManage = NSLocalizedString("Store.Subscriptions.Manage", comment: "Manage subscriptions")
    static let StoreProductSave = NSLocalizedString("Store.Product.Save", comment: "Save")
    
    // MARK: - Coins Store
    static let CoinsStoreTitle = NSLocalizedString("Store.Coins.Title", comment: "Add coins")
    static let CoinsStoreDescription = NSLocalizedString("Store.Coins.Description", comment: "Select coins pack")
}

// MARK: - Alert
extension String {
    static let AlertOk = NSLocalizedString("Alert.Ok", comment: "Ok")
    static let AlertCancel = NSLocalizedString("Alert.Cancel", comment: "Cancel")
    static let AlertError = NSLocalizedString("Alert.Error", comment: "Error")
}

// MARK: - Premium
extension String {
    static let PremiumAction = NSLocalizedString("Premium.Action", comment: "Join Premium")
}

// MARK: - Settings
extension String {
    static let Settings = NSLocalizedString("Settings", comment: "Settings")
    static let SettingsUI = NSLocalizedString("Settings.UI", comment: "UI")
    static let SettingsUIBackgroundColor = NSLocalizedString("Settings.UI.Background.Color", comment: "Background color")
    static let SettingsUIColorReset = NSLocalizedString("Settings.UI.Color.Reset", comment: "Reset")
    
    static let Version = NSLocalizedString("Version", comment: "Version")
}

// MARK: - Errors
extension String {
    static let ErrorNoInternet = NSLocalizedString("Error.NoInternet", comment: "The Internet connection appears to be offline")

    static let ErrorStoreProductsLoading = NSLocalizedString("Error.Store.ProductsLoading", comment: "Products loading error")
    static let ErrorStorePurchase = NSLocalizedString("Error.Store.Purchase", comment: "Failed to buy. Try again later")
    static let ErrorStoreRestore = NSLocalizedString("Error.Store.Restore", comment: "Failed to restore purchases. Try again later")
    
    static let ErrorCloudNoAccount = NSLocalizedString("Error.CloudKit.NoAccount", comment: "Make sure iCloud is authorised to save your game data")
    static let ErrorCloudNotAvailable = NSLocalizedString("Error.CloudKit.NotAvailable", comment: "iCloud synchronization is not available. Check settings or your internet connection to save your game data")
}
