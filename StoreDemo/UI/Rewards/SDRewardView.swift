//
//  SDRewardView.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

struct SDRewardViewConfiguration {
    let rewards: [SDReward]
    let title: String
}

class SDRewardView: UIView {
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var rewardsStackView: UIStackView!
    
    var configuration: SDRewardViewConfiguration! {
        didSet {
            configureRewards()
        }
    }
    
    /// Reward selection handler.
    var onSelect: ((_ reward: SDReward) -> Void)?
    /// All animations completion handler.
    var onComplete: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    /// Reset.
    func reset() {
        configureRewards()
    }
    
    private func configureRewards() {
        infoLabel.text = configuration.title
        
        for view in rewardsStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        var selectedReward: SDReward?
        for reward in configuration.rewards.shuffled() {
            let rewardView: SDRewardSelectionView = SDRewardSelectionView.fromNib()
            rewardView.reward = reward
            rewardView.onPress = {
                if selectedReward == nil {
                    selectedReward = reward
                    return true
                }
                return false
            }
            rewardView.onOpen = { [weak self] in
                self?.onSelect?(reward)
                self?.openOtherThan(selected: rewardView, completion: { [weak self] in
                    self?.onComplete?()
                })
            }
            rewardsStackView.addArrangedSubview(rewardView)
        }
    }
    
    private func openOtherThan(selected: SDRewardSelectionView, completion: @escaping () -> Void) {
        Task {
            for view in rewardsStackView.arrangedSubviews {
                if view != selected {
                    (view as? SDRewardSelectionView)?.open(completion: {})
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                completion()
            }
        }
    }
}
