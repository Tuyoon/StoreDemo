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
    
    private let rewardsManager = SDDIContainer.shared.resolve(SDRewardsManager.self)
    
    private lazy var presenter: SDMainPresenterProtocol = SDMainPresenter(
        navigator: SDMainNavigator(navigationController: navigationController!),
        delegate: self
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewWillDisappear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = SDSettings.backgroundColor
    }
    
    private func configure() {
        joinPremiumButton.sdSetAttribugedTitle(.PremiumAction)
        settingsButton.sdSetAttribugedTitle(.Settings)
    }
}

extension SDMainViewController: SDMainPresenterDelegate {
    func mainPresenter(presenter: any SDMainPresenterProtocol, didUpdatePremiumState hasPremium: Bool) {
        updatePremiumRelatedUI(hasPremium: hasPremium)
    }
    
    func mainPresenter(presenter: any SDMainPresenterProtocol, didUpdateCoins coins: Int) {
        updateCoinsUI(coins: coins)
    }
}

// MARK: - Actions

extension SDMainViewController {
    
    @IBAction private func coinsButtonPressed(_ sender: Any) {
        presenter.showCoinsStore()
    }
    
    @IBAction private func joinPremiumButtonPressed(_ sender: Any) {
        presenter.showPremiumStore()
    }
    
    @IBAction private func settingsButtonPressed(_ sender: Any) {
        presenter.showSettings()
    }
}

// MARK: - Private Methods. Game Center

extension SDMainViewController {
    private func authenticateGameCenter() {
        let gameCenter = SDDIContainer.shared.resolve(SDGameCenter.self)
        gameCenter.authenticate(from: self) { isAuthenticated in
            
        }
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
    private func updateCoinsUI(coins: Int) {
        coinsLabel.text = "\(coins)"
        coinsView.animateFilled()
    }
    
    /// Update premium related UI.
    @objc
    private func updatePremiumRelatedUI(hasPremium: Bool) {
        if hasPremium {
            premiumView.isHidden = true
            return
        }
        
        premiumView.isHidden = false
    }
}
