//
//  MainViewController.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit
import CloudKit

class SDMainViewController: UIViewController {

    @IBOutlet private weak var premiumView: UIView!
    @IBOutlet private weak var joinPremiumButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!
    
    @IBOutlet private weak var coinsView: UIView!
    @IBOutlet private weak var coinsLabel: UILabel!
    
    @IBOutlet private weak var iCloudBarButton: UIBarButtonItem!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = SDSettings.backgroundColor
        
        updatePremiumRelatedUI()
        
        SDApp.rate()
        updateCoinsUI()
        subscribeToNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showRewardsIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotifications()
    }
    
    private func configure() {
        joinPremiumButton.sdSetAttribugedTitle(.PremiumAction)
        settingsButton.sdSetAttribugedTitle(.Settings)
    }
    
    /// Show rewards if available.
    @objc
    private func showRewardsIfNeeded() {
        guard navigationController?.viewControllers.count == 1 else {
            return
        }
        
        guard let availableDailyRewards = SDRewardsManager.shared.availableDailyRewards() else {
            return
        }
        
        // Don't show rewards if another screen is presented.
        if navigationController!.presentedViewController != nil || navigationController!.viewControllers.count > 1 {
            return
        }
        guard let dailyRewardViewController = storyboard?.instantiateViewController(withIdentifier: "DailyRewardViewController") as? SDRewardViewController else {
            return
        }
        dailyRewardViewController.rewards = availableDailyRewards
        dailyRewardViewController.onSelect = { reward in
            SDRewardsManager.shared.dailyRewardReceived(reward)
        }
        dailyRewardViewController.onComplete = {
            dailyRewardViewController.dismiss(animated: false)
        }
        
        navigationController?.present(dailyRewardViewController, animated: false)
    }
}

// MARK: - Actions

extension SDMainViewController {
    
    @IBAction private func coinsButtonPressed(_ sender: Any) {
        showCoinsStore()
    }
    
    @IBAction private func joinPremiumButtonPressed(_ sender: Any) {
        showPremiumStore()
    }
    
    @IBAction private func settingsButtonPressed(_ sender: Any) {
        showSettings()
    }
}

// MARK: - Private Methods. Game Center

extension SDMainViewController {
    private func authenticateGameCenter() {
        SDGameCenter.shared.authenticate(from: self) { isAuthenticated in
            
        }
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updatePremiumRelatedUI), name: .SDStorePremiumStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCoinsUI), name: .UserStateCoinsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showRewardsIfNeeded), name: .RewardBecomeAvailable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showRewardsIfNeeded), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: .SDStorePremiumStateChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UserStateCoinsChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .RewardBecomeAvailable, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

// MARK: - Trait updates. Dark/Light scheme changes

extension SDMainViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColorTheme()
    }
    
    @objc
    private func updateColorTheme() {
        
    }
}

extension SDMainViewController {
    
    @objc
    private func updateCoinsUI() {
        coinsLabel.text = "\(SDUserState.shared.coins)"
        coinsView.animateFilled()
    }
    
    /// Update premium related UI.
    @objc
    private func updatePremiumRelatedUI() {
        if SDStore.shared.hasPremium {
            premiumView.isHidden = true
            return
        }
        
        premiumView.isHidden = false
    }
}

// MARK: - Private Methods. Screens

extension SDMainViewController {
    
    private func showSettings(completion: (() -> Void)? = nil) {
        guard let settingsNavigationController = storyboard?.instantiateViewController(withIdentifier: "SettingsNavigationController") as? UINavigationController else {
            return
        }
        let settingsViewController = settingsNavigationController.viewControllers.first as? SDSettingsViewController
        settingsViewController?.completion = completion
        navigationController?.present(settingsNavigationController, animated: true)
    }
    
    private func showCoinsStore(_ mode: SDCoinsStoreViewControllerMode = .default) {
        let storeNavigationViewController = SDCoinsStoreViewController.store(mode: mode)
        storeNavigationViewController.isModalInPresentation = true
        navigationController?.present(storeNavigationViewController, animated: true)
    }
    
    private func showPremiumStore() {
        guard let storeNavigationViewController = storyboard?.instantiateViewController(withIdentifier: "PremiumStoreNavigationController") as? UINavigationController else {
            return
        }
        storeNavigationViewController.isModalInPresentation = true
        navigationController?.present(storeNavigationViewController, animated: true)
    }
}
