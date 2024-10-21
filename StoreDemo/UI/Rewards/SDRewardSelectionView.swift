//
//  SDRewardSelectionView.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

class SDRewardSelectionView: UIView {

    @IBOutlet private weak var closedImageView: UIImageView!
    @IBOutlet private weak var openedView: UIView!
    @IBOutlet private weak var coinsView: UIView!
    @IBOutlet private weak var coinsLabel: UILabel!
    
    var reward: SDReward! {
        didSet {
            coinsLabel.text = "\(reward.coinsCount)"
        }
    }
    /// Reward selected.
    /// - Returns: true if can be opened. For the first reward when multitouch applied.
    /// - Returns: false for other rewards when multitouch applied.
    var onPress: (() -> Bool)?
    /// Reward opened.
    var onOpen: (() -> Void)?
    
    func open(completion: @escaping () -> Void) {
        openAnimated(animateCoins: false, completion: completion)
    }
    
    @IBAction private func buttonPressed(_ sender: Any) {
        if onPress?() == true {
            openAnimated(animateCoins: true, completion: { [weak self] in
                self?.onOpen?()
            })
        }
    }
    
    /// Open animated.
    /// 1. Animate card flip
    /// 2. Animate coins scale.
    private func openAnimated(animateCoins: Bool, completion: @escaping () -> Void) {
        // 1. Animate card flip
        UIView.transition(from: closedImageView, to: openedView, duration: 0.5, options: .transitionFlipFromRight, completion: { _ in
            if animateCoins {
                // 2. Animate coins scale.
                UIView.animate(withDuration: 0.5, animations: { [weak self] in
                    self?.coinsView.transform = CGAffineTransformMakeScale(1.2, 1.2)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.5, animations: { [weak self] in
                        self?.coinsView.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: { _ in
                        completion()
                    })
                })
            } else {
                completion()
            }
        })
    }
}
