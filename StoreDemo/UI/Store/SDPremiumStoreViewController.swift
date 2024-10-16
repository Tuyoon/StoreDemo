//
//  PremiumStoreViewController.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

class SDPremiumStoreViewController: UIViewController {
    
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private var featureViews: [SDStoreFeatureView] = []
    
    @IBOutlet private weak var purchasingView: UIView!
    @IBOutlet private weak var yearlyProductView: SDStoreProductView!
    @IBOutlet private weak var monthlyProductView: SDStoreProductView!
    
    @IBOutlet private weak var purchaseButton: UIButton!
    @IBOutlet private weak var restoreButton: UIButton!
    @IBOutlet private weak var manageSubscriptionsButton: UIButton!
    @IBOutlet private weak var redeemButton: UIButton!
    
    @IBOutlet private weak var productsLoadingErrorView: UIView!
    @IBOutlet private weak var productsLoadingErrorLabel: UILabel!
    
    @IBOutlet private weak var closeBarButtonItem: UIBarButtonItem!
    private var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localize()
        createActivityIndicatorView()
        configureFeaturesViews()
        configureProductsViews()
        configurePurchaseButton()
        updateInfo()
        updateInternetConnectionUI()
        subscribeForNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicatorView.frame = self.view.bounds
    }
    
    @objc private func premiumStateChangedNotification(_ notification: Notification) {
        updateInfo()
    }
}

// MARK: - Actions

extension SDPremiumStoreViewController {
    @IBAction private func manageSubscriptionsButtonPressed(_ sender: Any) {
        SDStore.shared.showManageSubscriptions()
    }
    
    @IBAction private func purchaseButtonPressed(_ sender: Any) {
        let product: SDStoreProduct
        if yearlyProductView.state == .selected {
            product = .yearlySubscription
        } else {
            product = .monthlySubscription
        }
        
        showActivity(true)
        SDStore.shared.buy(product: product) { [weak self] result in
            self?.showActivity(false)
            switch result {
                case .cancelled:
                    break
                case .error(let error):
                    self?.showErrorAlert(error: error)
                case .purchased:
                    break
            }
        }
    }
    
    @IBAction private func restoreButtonPressed(_ sender: Any) {
        showActivity(true)
        SDStore.shared.restore { [weak self] error in
            self?.showActivity(false)
            if let error {
                self?.showErrorAlert(error: error)
            }
        }
    }
    
    @IBAction private func redeemOfferCodeButtonPressed(_ sender: Any) {
        SDStore.shared.showOfferCodeRedeem()
    }
    
    @IBAction private func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - Private Methods

extension SDPremiumStoreViewController {
    
    private func subscribeForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(premiumStateChangedNotification), name: .SDStorePremiumStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProductsUI), name: .SDStoreProductsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateInternetConnectionUI), name: .SDNetworkMonitorStatusChanged, object: nil)
    }
    
    private func localize() {
        title = .PremiumStoreTitle
        purchaseButton.setTitle(.StorePurchase, for: .normal)
        restoreButton.setTitle(.StoreRestore, for: .normal)
        manageSubscriptionsButton.setTitle(.StoreSubscriptionsManage, for: .normal)
        redeemButton.setTitle(.StoreRedeem, for: .normal)
    }
    
    private func configureFeaturesViews() {
        let allFeatures = SDStoreFeature.allCases
        assert(allFeatures.count == featureViews.count, "Invalid features and views count")
        for i in 0..<featureViews.count {
            let featureView = featureViews[i]
            featureView.feature = allFeatures[i]
        }
    }
    
    private func configureProductsViews() {
        if let yearlyProduct = SDStore.shared.storeProduct(for: .yearlySubscription) {
            yearlyProductView.product = yearlyProduct
            if let monthlyProduct = SDStore.shared.storeProduct(for: .monthlySubscription) {
                yearlyProductView.fullPriceProduct = monthlyProduct
            }
            yearlyProductView.onSelect = { [weak self] in
                self?.purchaseButton.isEnabled = true
                self?.monthlyProductView.state = .default
            }
            yearlyProductView.state = .selected
            yearlyProductView.isHidden = false
        } else {
            yearlyProductView.isHidden = true
        }
        
        if let monthlyProduct = SDStore.shared.storeProduct(for: .monthlySubscription) {
            monthlyProductView.product = monthlyProduct
            monthlyProductView.onSelect = { [weak self] in
                self?.purchaseButton.isEnabled = true
                self?.yearlyProductView.state = .default
            }
            monthlyProductView.isHidden = false
        } else {
            monthlyProductView.isHidden = true
        }
    }
    
    private func configurePurchaseButton() {
        purchaseButton.setTitleColor(.atButtonText.withAlphaComponent(0.5), for: .disabled)
    }
    
    @objc
    private func updateInternetConnectionUI() {
        if SDNetworkMonitor.shared.isConnected {
            purchasingView.isHidden = false
            purchaseButton.isHidden = false
            productsLoadingErrorView.isHidden = true
            return
        }
        purchasingView.isHidden = true
        purchaseButton.isHidden = true
        productsLoadingErrorView.isHidden = false
        productsLoadingErrorLabel.text = .ErrorStoreProductsLoading
    }
    
    @objc
    private func updateProductsUI() {
        configureProductsViews()
    }
    
    private func createActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(frame: self.view.bounds)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.hidesWhenStopped = true
    }
    
    private func showActivity(_ show: Bool) {
        if show {
            closeBarButtonItem.isEnabled = false
            activityIndicatorView.startAnimating()
        } else {
            closeBarButtonItem.isEnabled = true
            activityIndicatorView.stopAnimating()
        }
    }
    
    private func updateInfo() {
        let state = SDStore.shared.state
        var info: String = ""
        switch state {
            case .none:
                info = .PremiumStoreDescription
                purchasingView.isHidden = false
                purchaseButton.isHidden = false
                manageSubscriptionsButton.isHidden = true
                redeemButton.isHidden = false
            case .subscribed(let date):
                info = String(format: .PremiumStoreSubscriptionActiveFormat, SDDateFormatters.standardString(from: date))
                purchasingView.isHidden = true
                purchaseButton.isHidden = true
                manageSubscriptionsButton.isHidden = false
                redeemButton.isHidden = true
            case .expired(let date):
                info = String(format: .PremiumStoreSubscriptionExpiredFormat, SDDateFormatters.standardString(from: date))
                purchasingView.isHidden = false
                purchaseButton.isHidden = false
                manageSubscriptionsButton.isHidden = false
                redeemButton.isHidden = false
        }
        infoLabel.text = info
    }
}
