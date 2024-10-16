//
//  SDRewardViewController.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

class SDRewardViewController: UIViewController {

    @IBOutlet private weak var rewardView: SDRewardView!
    
    var rewards: [SDReward] = []
    /// Reward selection handler.
    var onSelect: ((_ reward: SDReward) -> Void)?
    /// All animations completion handler.
    var onComplete: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rewardView.configuration = SDRewardViewConfiguration(rewards: rewards, title: .RewardDailyInfo)
        rewardView.onSelect = onSelect
        rewardView.onComplete = onComplete
    }
}
