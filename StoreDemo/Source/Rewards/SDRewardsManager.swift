//
//  RewardsManager.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

extension Notification.Name {
    static let RewardBecomeAvailable = Notification.Name("SDRewardBecomeAvailable")
}

enum SDRewardsManagerConstants {
    static let rewardAvailableNotificationIdentifier = "com.storedemo.rewardAvailableNotification"
    
    /// Daily reward at 10am.
    static let dateComponent: DateComponents = {
        var dateComponent = DateComponents()
        dateComponent.hour = 10
        dateComponent.minute = 0
        return dateComponent
    }()
}

enum SDReward: CaseIterable {
    case reward100
    case reward80
    case reward60
    case reward40
    case reward20
    
    var coinsCount: Int {
        switch self {
            case .reward100:
                return 100
            case .reward80:
                return 80
            case .reward60:
                return 60
            case .reward40:
                return 40
            case .reward20:
                return 20
        }
    }
}

class SDRewardsManager {
    static let shared = SDRewardsManager()
    
    /// Timer used for time change protection.
    private var rewardTimer: Timer?
    
    private var isDailyRewardAvailable: Bool {
        // Not available untile timer fired
        if rewardTimer != nil {
            return false
        }
        
        guard let nextDailyRewardDate = SDCloudKitDatabase.shared.nextDailyRewardDate else {
            return false
        }
        
        if Date() >= nextDailyRewardDate {
            return true
        }
        return false
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(userStateChangedNotification), name: .UserStateUpdated, object: nil)
    }
    
    deinit {
        stopRewardTimer()
        NotificationCenter.default.removeObserver(self, name: .UserStateUpdated, object: nil)
    }
    
    @objc
    private func userStateChangedNotification(_ notification: Notification) {
        // Not available untile timer fired
        if rewardTimer != nil {
            return
        }
        
        if let nextDailyRewardDate = SDCloudKitDatabase.shared.nextDailyRewardDate, Date() >= nextDailyRewardDate {
            NotificationCenter.default.post(name: .RewardBecomeAvailable, object: nil)
        }
    }
    
    /// Available daily rewards.
    func availableDailyRewards() -> [SDReward]? {
        if isDailyRewardAvailable {
            return SDReward.allCases.shuffled()
        }
        return nil
    }
    
    /// Daily reward received. Updates next reward notification.
    func dailyRewardReceived(_ reward: SDReward) {
        SDUserState.shared.addCoins(reward.coinsCount)
        
        let nextDailyRewardDate = Calendar.current.nextDate(after: Date(), matching: SDRewardsManagerConstants.dateComponent, matchingPolicy: .nextTime)!
        SDCloudKitDatabase.shared.updateNextDailyRewardDate(nextDailyRewardDate)
        updateRewardNotification(nextDailyRewardDate)
    }
    
    private func updateRewardNotification(_ nextDailyRewardDate: Date) {
        let timeInterval = nextDailyRewardDate.timeIntervalSinceNow
        if timeInterval > 0 {
            stopRewardTimer()
            startRewardTimer(timeInterval)
            SDNotifications.scheduleNotification(id: SDRewardsManagerConstants.rewardAvailableNotificationIdentifier,
                                                 timeInterval: timeInterval,
                                                 title: .PushNotificationDailyRewardAvailableTitle,
                                                 body: .PushNotificationDailyRewardAvailableMessage,
                                                 soundType: .coins,
                                                 badge: 1)
        }
    }
    
    private func startRewardTimer(_ timeInterval: TimeInterval) {
        rewardTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(rewardBecomeAvailable), userInfo: nil, repeats: false)
    }
    
    private func stopRewardTimer() {
        rewardTimer?.invalidate()
        rewardTimer = nil
    }
    
    @objc
    private func rewardBecomeAvailable() {
        rewardTimer = nil
        if isDailyRewardAvailable {
            NotificationCenter.default.post(name: .RewardBecomeAvailable, object: nil)
        }
    }
}
