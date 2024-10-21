//
//  SDMainNavigator.swift
//  StoreDemo
//
//  Created by Admin on 21.10.2024.
//

import UIKit

protocol SDMainNavigatorProtocol {
    var navigationController: UINavigationController { get }
    func showPremiumStore()
    func showCoinsStore()
    func showSettings()
    func showRewards(_ rewards: [SDReward], completion: @escaping (_ reward: SDReward) -> Void)
}

class SDMainNavigator: SDMainNavigatorProtocol {
    var navigationController: UINavigationController
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showPremiumStore() {
        guard let storeNavigationViewController = navigationController.storyboard?.instantiateViewController(withIdentifier: "PremiumStoreNavigationController") as? UINavigationController else {
            return
        }
        storeNavigationViewController.isModalInPresentation = true
        navigationController.present(storeNavigationViewController, animated: true)
    }
    
    func showCoinsStore() {
        let storeNavigationViewController = SDCoinsStoreViewController.store(mode: .default)
        storeNavigationViewController.isModalInPresentation = true
        navigationController.present(storeNavigationViewController, animated: true)
    }
    
    func showSettings() {
        guard let settingsNavigationController = navigationController.storyboard?.instantiateViewController(withIdentifier: "SettingsNavigationController") as? UINavigationController else {
            return
        }
        navigationController.present(settingsNavigationController, animated: true)
    }
    
    func showRewards(_ rewards: [SDReward], completion: @escaping (_ reward: SDReward) -> Void) {
        guard let dailyRewardViewController = navigationController.storyboard?.instantiateViewController(withIdentifier: "DailyRewardViewController") as? SDRewardViewController else {
            return
        }
        dailyRewardViewController.rewards = rewards
        dailyRewardViewController.onSelect = { reward in
            completion(reward)
        }
        dailyRewardViewController.onComplete = {
            dailyRewardViewController.dismiss(animated: false)
        }
        
        navigationController.present(dailyRewardViewController, animated: false)
    }
}
