//
//  SDMainPresenter.swift
//  StoreDemo
//
//  Created by Admin on 21.10.2024.
//

import Foundation
import UIKit

protocol SDMainPresenterDelegate: AnyObject {
    func mainPresenter(presenter: SDMainPresenterProtocol, didUpdatePremiumState hasPremium: Bool)
    func mainPresenter(presenter: SDMainPresenterProtocol, didUpdateCoins coins: Int)
}

protocol SDMainPresenterProtocol {
    var coins: Int { get }
    var hasPremium: Bool { get }
    var isDailyRewardAvailable: Bool { get }
    var delegate: SDMainPresenterDelegate? { get set }
    
    func viewWillAppear()
    func viewDidAppear()
    func viewWillDisappear()
    
    func showPremiumStore()
    func showCoinsStore()
    func showSettings()
}

class SDMainPresenter: SDMainPresenterProtocol {
    
    private let userState = SDDIContainer.shared.resolve(SDUserState.self)
    private let store = SDDIContainer.shared.resolve(SDStore.self)
    private let rewardsManager = SDDIContainer.shared.resolve(SDRewardsManager.self)
    
    var coins: Int {
        return userState.coins
    }
    var hasPremium: Bool {
        return store.hasPremium
    }
    var isDailyRewardAvailable: Bool {
        return (rewardsManager.availableDailyRewards()?.count ?? 0) > 0
    }
    
    private let navigator: SDMainNavigatorProtocol
    weak var delegate: SDMainPresenterDelegate?
    
    init(navigator: SDMainNavigatorProtocol, delegate: SDMainPresenterDelegate? = nil) {
        self.navigator = navigator
        self.delegate = delegate
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
    
    func viewWillAppear() {
        subscribeToNotifications()
        SDApp.rate()
        delegate?.mainPresenter(presenter: self, didUpdateCoins: coins)
        delegate?.mainPresenter(presenter: self, didUpdatePremiumState: hasPremium)
    }
    
    func viewDidAppear() {
        showRewardsIfNeeded()
    }
    
    func viewWillDisappear() {
        unsubscribeFromNotifications()
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(premiumStateChangedNotification), name: .SDStorePremiumStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(coinsChangedNotification), name: .UserStateCoinsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rewardBecomeAvailableNotification), name: .RewardBecomeAvailable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rewardBecomeAvailableNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: .SDStorePremiumStateChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UserStateCoinsChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .RewardBecomeAvailable, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

extension SDMainPresenter {
    /// Show rewards if available.
    @objc
    private func showRewardsIfNeeded() {
        guard let availableDailyRewards = rewardsManager.availableDailyRewards() else {
            return
        }
        
        navigator.showRewards(availableDailyRewards) { [weak self] reward in
            self?.rewardsManager.dailyRewardReceived(reward)
        }
    }
}
// MARK: - Private Methods. Screens

extension SDMainPresenter {
    
    func showPremiumStore() {
        navigator.showPremiumStore()
    }
    
    func showCoinsStore() {
        navigator.showCoinsStore()
    }
    
    func showSettings() {
        navigator.showSettings()
    }
}

extension SDMainPresenter {
    @objc
    private func premiumStateChangedNotification(_ notification: Notification) {
        delegate?.mainPresenter(presenter: self, didUpdatePremiumState: hasPremium)
    }
    
    @objc
    private func coinsChangedNotification(_ notification: Notification) {
        delegate?.mainPresenter(presenter: self, didUpdateCoins: coins)
    }
    
    @objc
    private func rewardBecomeAvailableNotification(_ notification: Notification) {
        showRewardsIfNeeded()
    }
}
