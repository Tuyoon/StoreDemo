//
//  SDStore.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import Foundation
import StoreKit

/// Notifications.
extension Notification.Name {
    static let SDStorePremiumStateChanged = Notification.Name("SDStorePremiumStateChangedNotification")
    static let SDStoreProductsChanged = Notification.Name("SDStoreProductsChangedNotification")
}

/// Product.
enum SDStoreProduct: String, CaseIterable {
    static var consumableProducts: [SDStoreProduct] = [
        .coins1000,
        .coins500,
        .coins250,
    ]
    
    case yearlySubscription = "com.storedemo.year"
    case monthlySubscription = "com.storedemo.month"
    
    case coins1000 = "com.storedemo.coins.1000"
    case coins500 = "com.storedemo.coins.500"
    case coins250 = "com.storedemo.coins.250"
}

/// 
private enum SDStoreConstants {
    /// Subscription expiration grace period.
#if DEBUG
    static let subscriptionExpirationGracePeriod: TimeInterval = 10
#else
    static let subscriptionExpirationGracePeriod: TimeInterval = 10 * 60
#endif
}

private enum SDStoreError: LocalizedError {
    case productNotLoaded
    
    case failedVerification
    case failedPurchase
    case failedRestore
    
    var errorDescription: String? {
        switch self {
            case .productNotLoaded:
                return .ErrorStoreProductsLoading
            case .failedPurchase:
                return .ErrorStorePurchase
            case .failedRestore:
                return .ErrorStoreRestore
            default:
                return nil
        }
    }
}

enum SDPurchasingResult {
    case cancelled
    case error(error: Error)
    case purchased
}

enum SDStoreState {
    case none
    case subscribed(date: Date)
    case expired(date: Date)
}

class SDStore {
    /// Coins products.
    var coinsProducts: [SDStoreProduct] = [
        .coins1000,
        .coins500,
        .coins250
    ]
    
    private var updates: Task<Void, Never>? = nil
    private var productsMap: [String: Product] = [:]
    
    private var subscriptionExpirationTimer: Timer?
    
    @SDUserDefaulltsStoredValue(defaultValue: nil, key: "store-subscriptionExpirationDate")
    private var savedSubscriptionExpirationDate: Date?
    private var subscriptionExpirationDate: Date? {
        get {
            database.subscriptionExpirationDate ?? savedSubscriptionExpirationDate
        }
        set {
            if let newValue {
                savedSubscriptionExpirationDate = newValue
                database.updateSubscriptionExpirationDate(newValue)
                sendPremiumStateChangedNotification()
                startSubscriptionExpirationTimer()
            } else {
                // Invalid state
            }
        }
    }
    
    private let userState: SDUserState
    private let database: SDCloudKitDatabaseProtocol
    private let networkMonitor: SDNetworkMonitor
    
    var hasPremium: Bool {
        if let subscriptionExpirationDate {
            return Date() < subscriptionExpirationDate
        }
        return false
    }
    
    var state: SDStoreState {
        if hasPremium {
            return .subscribed(date: subscriptionExpirationDate!)
        }
        if let subscriptionExpirationDate {
            return .expired(date: subscriptionExpirationDate)
        }
        return .none
    }

    init(userState: SDUserState,
         database: SDCloudKitDatabaseProtocol,
         networkMonitor: SDNetworkMonitor) {
        self.userState = userState
        self.database = database
        self.networkMonitor = networkMonitor
        
        updates = newTransactionListenerTask()
        startSubscriptionExpirationTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(userStateUpdatedNotification), name: .UserStateUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(networkMonitorStatusChanged), name: .SDNetworkMonitorStatusChanged, object: nil)
    }
    
    deinit {
        // Cancel the update handling task when you deinitialize the class.
        updates?.cancel()
        stopSubscriptionExpirationTimer()
        NotificationCenter.default.removeObserver(self, name: .UserStateUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: .SDNetworkMonitorStatusChanged, object: nil)
    }
    
    @objc private func userStateUpdatedNotification(_ notification: Notification) {
        if let remoteSubscriptionExpirationDate = database.subscriptionExpirationDate {
            if let savedSubscriptionExpirationDate, remoteSubscriptionExpirationDate < savedSubscriptionExpirationDate {
                return
            }
            savedSubscriptionExpirationDate = remoteSubscriptionExpirationDate
            sendPremiumStateChangedNotification()
            startSubscriptionExpirationTimer()
        }
    }
    
    /// Network monitor status change notification handler.
    @objc
    private func networkMonitorStatusChanged(_ notification: Notification) {
        guard networkMonitor.isConnected else {
            return
        }
        if productsMap.isEmpty {
            Task {
                await fetchProducts()
                await updatePremiumState()
            }
        }
    }
}

// MARK: - SDStoreProtocol

extension SDStore {
    
    /// Initialize store.
    func initialize() {
        guard networkMonitor.isConnected else {
            return
        }
        Task {
            await fetchProducts()
            await updatePremiumState()
        }
    }
    
    /// Return SK Product for specified product type.
    func storeProduct(for product: SDStoreProduct) -> Product? {
        return productsMap[product.rawValue]
    }
    
    /// Buy specified product.
    func buy(product: SDStoreProduct, completion: @escaping (_ result: SDPurchasingResult) -> Void) {
        guard networkMonitor.isConnected else {
            completion(.error(error: SDNetworkMonitorError.noInternet))
            return
        }
        guard let storeProduct = productsMap[product.rawValue] else {
            completion(.error(error: SDStoreError.productNotLoaded))
            return
        }
        Task {
            do {
                let result = try await storeProduct.purchase()
                switch result {
                    case .success(let verification):
                        // Check whether the transaction is verified. If it isn't,
                        // this function rethrows the verification error.
                        let transaction = try checkVerified(verification)
                        await applyTransaction(transaction)
                        // Always finish transaction.
                        await transaction.finish()
                    case .userCancelled:
                        DispatchQueue.main.async {
                            completion(.cancelled)
                        }
                        return
                    case .pending:
                        break
                    default:
                        break
                }
                DispatchQueue.main.async {
                    completion(.purchased)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(.error(error: SDStoreError.failedPurchase))
                }
            }
        }
    }
    
    /// Coins for purchased product.
    func coinsForProduct(id: String) -> Int {
        switch id {
            case SDStoreProduct.coins1000.rawValue:
                return 1000
            case SDStoreProduct.coins500.rawValue:
                return 500
            case SDStoreProduct.coins250.rawValue:
                return 250
            default:
                return 0
        }
    }
    
    /// Restore purchases.
    func restore(completion: @escaping (_ error: Error?) -> Void) {
        guard networkMonitor.isConnected else {
            completion(SDNetworkMonitorError.noInternet)
            return
        }
        Task {
            do {
                try await AppStore.sync()
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(SDStoreError.failedRestore)
                }
            }
        }
    }
    
    /// Open subscription manage screen.
    func showManageSubscriptions() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene else {
            return
        }
        Task {
            try? await AppStore.showManageSubscriptions(in: scene)
        }
    }
    
    /// Open redeem sheet.
    func showOfferCodeRedeem() {
        if #available(iOS 16.0, *) {
            guard let scene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene else {
                return
            }
            Task { @MainActor in
                try? await AppStore.presentOfferCodeRedeemSheet(in: scene)
            }
        } else {
            SKPaymentQueue.default().presentCodeRedemptionSheet()
        }
    }
}

// MARK: - Private Methods. Listener

private extension SDStore {
    private func newTransactionListenerTask() -> Task<Void, Never> {
        return Task.detached { [weak self] in
            guard let self else {
                return
            }
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    // Add coins or update premium state.
                    await applyTransaction(transaction)
                    // Finish transaction always.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                }
            }
        }
    }
    
    /// Add coins or update premium state.
    private func applyTransaction(_ transaction: Transaction) async {
        switch transaction.productType {
            case .consumable:
                let coins = coinsForProduct(id: transaction.productID)
                userState.addCoins(coins)
            default:
                await updatePremiumState()
        }
    }
    
    @MainActor
    private func updatePremiumState() async {
        /*
         В Transaction.currentEntitlements enumerated only:
         1 non-consumable
         2 latest transaction for each auto-renewable subscription
         3 latest transaction for each non-renewing, including finished ones
         */
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                // Check the `productType` of the transaction and get the corresponding product from the store.
                switch transaction.productType {
                    case .consumable:
                        break
                    case .nonConsumable:
                        break
                    case .nonRenewable:
                        break
                    case .autoRenewable:
                        if let expirationDate = transaction.expirationDate {
                            if let subscriptionExpirationDate {
                                if subscriptionExpirationDate < expirationDate {
                                    self.subscriptionExpirationDate = expirationDate
                                }
                            } else {
                                self.subscriptionExpirationDate = expirationDate
                            }
                        }
                    default:
                        break
                }
            }
            catch {
                
            }
        }
    }
}

// MARK: - Private Methods

extension SDStore {
    
    @MainActor
    private func fetchProducts() async {
        do {
            let products: [Product] = try await Product.products(for: SDStoreProduct.allCases.map({$0.rawValue}))
            
            products.forEach { product in
                self.productsMap[product.id] = product
            }
            sendProductsChangeNotification()
        }
        catch {
            
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
            case .unverified:
                // StoreKit parses the JWS, but it fails verification.
                throw SDStoreError.failedVerification
            case .verified(let safe):
                // The result is verified. Return the unwrapped value.
                return safe
        }
    }
    
    private func sendPremiumStateChangedNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .SDStorePremiumStateChanged, object: self.hasPremium)
        }
    }
    
    private func sendProductsChangeNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .SDStoreProductsChanged, object: nil)
        }
    }
}

// MARK: - Private Methods. Subscription Expiration Timer

extension SDStore {
    private func startSubscriptionExpirationTimer() {
        stopSubscriptionExpirationTimer()
        
        if hasPremium {
            let timeInterval = subscriptionExpirationDate!.timeIntervalSinceNow + SDStoreConstants.subscriptionExpirationGracePeriod
            subscriptionExpirationTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateStatus), userInfo: nil, repeats: false)
        }
    }
    
    private func stopSubscriptionExpirationTimer() {
        subscriptionExpirationTimer?.invalidate()
    }
    
    @objc
    private func updateStatus() {
        sendPremiumStateChangedNotification()
    }
}
