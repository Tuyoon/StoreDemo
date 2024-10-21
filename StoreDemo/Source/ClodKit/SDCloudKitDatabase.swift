//
//  CloudKitDatabase.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import CloudKit
import UIKit

enum SDCloudState {
    case available
    case unavailable
    case restricted
    case noAccount
    case temporarilyUnavailable
    case couldNotDetermine
    case loading
    case uploading
}

extension CKAccountStatus {
    var state: SDCloudState {
        switch self {
            case .couldNotDetermine:
                return .couldNotDetermine
            case .available:
                return .available
            case .restricted:
                return .restricted
            case .noAccount:
                return .noAccount
            case .temporarilyUnavailable:
                return .temporarilyUnavailable
            @unknown default:
                return .unavailable
        }
    }
}

private enum Keys {
    /// Coins amount.
    static let coins = "coins"
    /// Coins update date.
    static let coinsUpdateDate = "coinsUpdateDate"
    /// Next daily reward date.
    static let nextDailyRewardDate = "nextDailyRewardDate"
    /// Subscription expiration date.
    static let subscriptionExpirationDate = "subscriptionExpirationDate"
}

/// Local constants.
private enum SDCloudKitDatabaseConstants {
    static let cloudKitContainerID = "iCloud.com.storedemo"
    static let userStateRecordID = CKRecord.ID(recordName: "me")
    static let userStateSubscriptionID: CKSubscription.ID = "cloudkit-user-state-changes"
}

/// Notifications.
extension Notification.Name {
    static let UserStateUpdated = Notification.Name("SDUserStateUpdated")
    static let CloudStatusChanged = Notification.Name("SDCloudStatusChanged")
}

/// Cloud record type.
enum SDCloudRecordType: String {
    case userState
}

/// Cloud database error.
private enum SDCloudKitDatabaseError: LocalizedError {
    case iCloudNoAccount
    case iCloudNotAvailable
    
    var errorDescription: String? {
        switch self {
            case .iCloudNoAccount:
                return .ErrorCloudNoAccount
            case .iCloudNotAvailable:
                return .ErrorCloudNotAvailable
        }
    }
}

protocol SDCloudKitDatabaseDelegate {
    func cloudKitDatabaseDidLoad(_ database: SDCloudKitDatabase)
    func cloudKitDatabase(_ database: SDCloudKitDatabase, didLoadCoins coins: Int)
}

protocol SDCloudKitDatabaseProtocol {
    var delegate: SDCloudKitDatabaseDelegate? { get set }
    
    var nextDailyRewardDate: Date? { get }
    func updateNextDailyRewardDate(_ date: Date)
    
    var coins: Int { get }
    func updateCoins(_ coins: Int)
    
    var subscriptionExpirationDate: Date? { get }
    func updateSubscriptionExpirationDate(_ date: Date)
}

/// CloudKitDatabase
class SDCloudKitDatabase: SDCloudKitDatabaseProtocol {
    
    private static let container: CKContainer = CKContainer(identifier: SDCloudKitDatabaseConstants.cloudKitContainerID)
    private var database: CKDatabase!
    
    var delegate: SDCloudKitDatabaseDelegate?
    
    private var userStateRecord: CKRecord!
    
    /// Subscription expiration date.
    private(set) var subscriptionExpirationDate: Date?
    
    /// Coins.
    @SDUserDefaulltsStoredValue(defaultValue: 0, key: "user-state-coins")
    private(set) var coins: Int
    /// Date of coin update. Used to determine actual value.
    @SDUserDefaulltsStoredValue(defaultValue: Date(timeIntervalSinceReferenceDate: 0), key: "user-state-coinsUpdateDate")
    private(set) var coinsUpdateDate: Date
    
    /// The next date for receiving the daily reward.
    /// Set after claiming the current reward.
    @SDUserDefaulltsStoredValue(defaultValue: nil, key: "user-state-nextDailyRewardDate")
    private(set) var nextDailyRewardDate: Date?
    
    /// Determines whether or not the iCloud change notification been added.
    @SDUserDefaulltsStoredValue(defaultValue: false, key: "cloudkit-subscriptionsAddedKey")
    private var isSubscriptionsAdded: Bool
    
    private var iCloudDataLoaded: Bool = false
    private var isUserStateLoading: Bool = false
    private var isGamesHistoryLoading: Bool = false
    
    private(set) var isCloudAvailable: Bool = false
    private var accountStatus: CKAccountStatus = .couldNotDetermine
    private let networkMonitor: SDNetworkMonitorProtocol
    
#if !targetEnvironment(simulator)
    init(networkMonitor: SDNetworkMonitorProtocol) {
        self.networkMonitor = networkMonitor
        NotificationCenter.default.addObserver(self, selector: #selector(accounChangedNotification), name: NSNotification.Name.CKAccountChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(networkMonitorStatusChanged), name: .SDNetworkMonitorStatusChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.CKAccountChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .SDNetworkMonitorStatusChanged, object: nil)
    }
    
    func load(onError: @escaping (_ error: Error?) -> Void) {
        Task {
            let accountStatus = try await SDCloudKitDatabase.container.accountStatus()
            self.accountStatus = accountStatus
            
            guard accountStatus == .available else {
                DispatchQueue.main.async {
                    switch accountStatus {
                        case .noAccount:
                            onError( SDCloudKitDatabaseError.iCloudNoAccount)
                        default:
                            onError( SDCloudKitDatabaseError.iCloudNotAvailable)
                    }
                }
                notifyAboutCloudStatusChange(state: accountStatus.state)
                return
            }
            
            if networkMonitor.isConnected {
                configureDatabaseAndLoad { [weak self] in
                    self?.isCloudAvailable = true
                }
            }
            notifyAboutCloudStatusChange(state: accountStatus.state)
        }
    }
    
    private func configureDatabaseAndLoad(completion: (() -> Void)? = nil) {
        guard database == nil else {
            return
        }
        
        // Get a reference to the user's private database.
        self.database = SDCloudKitDatabase.container.privateCloudDatabase
        
        // Create a configuration with a higher-priority quality of service.
        let config = CKOperation.Configuration()
        config.qualityOfService = .userInitiated
        
        // Configure the database and execute the fetch.
        database?.configuredWith(body: { [weak self] configuredDatabase in
            self?.addSubscriptions()
            self?.loadUserState()
            
            DispatchQueue.main.async {
                completion?()
            }
        })
    }
    
    /// iCloud accound data change notification handler.
    @objc
    private func accounChangedNotification(_ notification: Notification) {
        Task {
            let accountStatus = try await SDCloudKitDatabase.container.accountStatus()
            self.accountStatus = accountStatus
            notifyAboutCloudStatusChange(state: accountStatus.state)
            
            guard accountStatus == .available else {
                isCloudAvailable = false
                return
            }
            
            isCloudAvailable = true
            
            if iCloudDataLoaded {
                syncUserState()
            } else {
                configureDatabaseAndLoad()
            }
        }
    }
    
    /// Network status change notification handler.
    @objc
    private func networkMonitorStatusChanged(_ notification: Notification) {
        guard networkMonitor.isConnected else {
            return
        }
        if database == nil {
            configureDatabaseAndLoad()
            return
        }
        if iCloudDataLoaded == false {
            self.addSubscriptions()
            self.loadUserState()
        }
    }
    
    /// Add subscription for user status notification.
    private func addSubscriptions() {
        // Use a local flag to avoid saving the subscription more than once.
        guard isSubscriptionsAdded == false else {
            return
        }
        
        // We set shouldSendContentAvailable to true to indicate we want CloudKit
        // to use silent pushes, which won’t bother the user (and which don’t require
        // user permission.)
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = ""
        
        // State notification.
        let predicate = NSPredicate(value: true)
        let userStateSubscription = CKQuerySubscription(recordType: SDCloudRecordType.userState.rawValue,
                                               predicate: predicate,
                                               subscriptionID: SDCloudKitDatabaseConstants.userStateSubscriptionID,
                                               options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
        userStateSubscription.notificationInfo = notificationInfo
        
        let subscriptionsToSave = [userStateSubscription]
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: subscriptionsToSave, subscriptionIDsToDelete: [])
        operation.modifySubscriptionsResultBlock = { [weak self] result in
            switch result {
                case .success:
                    self?.isSubscriptionsAdded = true
                case .failure:
                    break
            }
        }
        operation.qualityOfService = .userInitiated
        
        database.add(operation)
    }
    
    /// iCloud user state change notification received.
    /// - Returns: true when data updated
    func handleNotification(_ notification: CKNotification?) -> Bool {
        if notification?.subscriptionID == SDCloudKitDatabaseConstants.userStateSubscriptionID {
            loadUserState()
            return true
        }
        return false
    }
#endif
}

// MARK: - User State: Subscription, energy, rewards, etc.

extension SDCloudKitDatabase {
    func updateCoins(_ coins: Int) {
        self.coins = coins
        coinsUpdateDate = Date()
        syncUserState()
    }
    
    func updateSubscriptionExpirationDate(_ date: Date) {
        subscriptionExpirationDate = date
        syncUserState()
    }
    
    func updateNextDailyRewardDate(_ date: Date) {
        // Soft protection from time change. Save new date only.
        if let nextDailyRewardDate, nextDailyRewardDate > date {
            return
        }
        nextDailyRewardDate = date
        syncUserState()
    }
    
    /// Save user state.
    private func syncUserState() {
#if !targetEnvironment(simulator)
        updateUserStateRecord()
        
        guard let userStateRecord else {
            return
        }
        
        notifyAboutCloudStatusChange(state: .uploading)
        let saveOperation = CKModifyRecordsOperation(recordsToSave: [userStateRecord], recordIDsToDelete: nil)
        saveOperation.modifyRecordsResultBlock = { [weak self] result in
            guard let self else {
                return
            }
            switch result {
                case .success:
                    self.notifyAboutCloudStatusChange(state: self.accountStatus.state)
                case .failure:
                    break
            }
        }
        database.add(saveOperation)
#endif
    }
    
#if !targetEnvironment(simulator)
    private func loadUserState() {
        if isUserStateLoading {
            return
        }
        isUserStateLoading = true
        
        Task {
            do {
                notifyAboutCloudStatusChange(state: .loading)
                let matchResults = try await database.records(for: [SDCloudKitDatabaseConstants.userStateRecordID])
                let userStateRecords = matchResults.compactMap { _, result in try? result.get() }
                notifyAboutCloudStatusChange(state: accountStatus.state)
                
                guard let userStateRecord = userStateRecords.first else {
                    createUserStateRecord()
                    syncUserState()
                    return
                }
                
                iCloudDataLoaded = true
                
                updateUserStateFromRecord(userStateRecord)
            } catch {
                createUserStateRecord()
                syncUserState()
            }
            isUserStateLoading = false
        }
    }
    
    private func createUserStateRecord() {
        let recordID = SDCloudKitDatabaseConstants.userStateRecordID
        let record = CKRecord(recordType: SDCloudRecordType.userState.rawValue, recordID: recordID)
        self.userStateRecord = record
        updateUserStateRecord()
    }
    
    private func updateUserStateRecord() {
        guard let userStateRecord else {
            return
        }
        
        userStateRecord[Keys.coins] = coins
        userStateRecord[Keys.coinsUpdateDate] = coinsUpdateDate
        
        userStateRecord[Keys.subscriptionExpirationDate] = subscriptionExpirationDate
        
        userStateRecord[Keys.nextDailyRewardDate] = nextDailyRewardDate
    }
    
    /// Update state from iCloud
    private func updateUserStateFromRecord(_ record: CKRecord) {
        self.userStateRecord = record
        
        var isStateChanged = false
        
        if let remoteCoins = userStateRecord[Keys.coins] as? Int,
           let remoteCoinsUpdateDate = userStateRecord[Keys.coinsUpdateDate] as? Date {
            if coinsUpdateDate > remoteCoinsUpdateDate {
                // User received coins, iCloud record update is required.
                isStateChanged = true
            } else {
                if self.coins != remoteCoins {
                    // Local data is obsolete, update is required.
                    self.coins = remoteCoins
                    self.delegate?.cloudKitDatabase(self, didLoadCoins: remoteCoins)
                }
            }
        }
        
        if let remoteNextDailyRewardDate = userStateRecord[Keys.nextDailyRewardDate] as? Date {
            if let nextDailyRewardDate {
                if nextDailyRewardDate > remoteNextDailyRewardDate {
                    // Reward received before data loaded
                    isStateChanged = true
                } else {
                    self.nextDailyRewardDate = remoteNextDailyRewardDate
                }
            } else {
                self.nextDailyRewardDate = remoteNextDailyRewardDate
            }
        }
        
        if let remoteSubscriptionExpirationDate = userStateRecord[Keys.subscriptionExpirationDate] as? Date {
            // Save new subscription expiration date if needed.
            if let subscriptionExpirationDate, subscriptionExpirationDate > remoteSubscriptionExpirationDate {
                isStateChanged = true
            } else {
                self.subscriptionExpirationDate = remoteSubscriptionExpirationDate
            }
        }
        
        if isStateChanged {
            syncUserState()
        }
        
        notifyAboutUserStateUpdate()
    }
    
    private func notifyAboutUserStateUpdate() {
        DispatchQueue.main.async { [weak self] in
            NotificationCenter.default.post(name: .UserStateUpdated, object: nil)
            if let self {
                delegate?.cloudKitDatabaseDidLoad(self)
            }
        }
    }
        
    private func notifyAboutCloudStatusChange(state: SDCloudState) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .CloudStatusChanged, object: state)
        }
    }
#endif
}
