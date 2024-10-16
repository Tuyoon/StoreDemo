//
//  CoinsStoreViewController.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

/// Store mode.
enum SDCoinsStoreViewControllerMode {
    /// Default mode.
    case `default`
}

class SDCoinsStoreViewController: UIViewController {

    var mode: SDCoinsStoreViewControllerMode = .default
    var completion: ((_ isPurchased: Bool) -> Void)?
    
    private var products = SDStore.shared.coinsProducts
    private var selectedProduct: SDStoreProduct?
    
    @IBOutlet private weak var coinsLabel: UILabel!
    @IBOutlet private weak var coinsView: UIView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var productsStackView: UIStackView!
    
    @IBOutlet private weak var productsLoadingErrorView: UIView!
    @IBOutlet private weak var productsLoadingErrorLabel: UILabel!
    
    @IBOutlet private weak var redeemButton: UIButton!
    
    @IBOutlet private weak var purchaseButton: UIButton!
    @IBOutlet private weak var closeBarButtonItem: UIBarButtonItem!
    
    private var activityIndicatorView: UIActivityIndicatorView!
    
    static func store(mode: SDCoinsStoreViewControllerMode,
                      completion: ((_ isPurchased: Bool) -> Void)? = nil) -> UINavigationController {
        let storeNavigationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoinsStoreNavigationController") as! UINavigationController
        let storeViewController = storeNavigationViewController.viewControllers.first as! SDCoinsStoreViewController
        
        storeViewController.mode = mode
        storeViewController.completion = completion
        return storeNavigationViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
    
    private func configure() {
        localize()
        createActivityIndicatorView()
        updateCoinsView()
        configureProductsViews()
        configurePurchaseButton()
        updatePurchaseButton()
        updateInternetConnectionUI()
        subscribeForNotifications()
    }
    
    private func subscribeForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateInternetConnectionUI), name: .SDNetworkMonitorStatusChanged, object: nil)
    }
    
    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: .SDNetworkMonitorStatusChanged, object: nil)
    }
    
    private func localize() {
        title = .CoinsStoreTitle
        infoLabel.text = .CoinsStoreDescription
        
        purchaseButton.setTitle(.StorePurchase, for: .normal)
        productsLoadingErrorLabel.text = .ErrorStoreProductsLoading
    }
    
    private func updateCoinsView() {
        coinsLabel.text = "\(SDUserState.shared.coins)"
    }
    
    private func updateCoinsViewAnimated() {
        coinsLabel.text = "\(SDUserState.shared.coins)"
        coinsView.animateFilled()
    }
    
    private func configureProductsViews() {
        productsStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        for product in products {
            let productView: SDStoreProductView = SDStoreProductView.fromNib()
            productView.product = SDStore.shared.storeProduct(for: product)
            productView.onSelect = { [weak self] in
                self?.selectedProduct = product
                self?.clearProductSelection()
                productView.state = .selected
                self?.updatePurchaseButton()
            }
            productsStackView.addArrangedSubview(productView)
        }
    }
    
    @objc
    private func updateInternetConnectionUI() {
        if SDNetworkMonitor.shared.isConnected {
            infoLabel.isHidden = false
            productsStackView.isHidden = false
            redeemButton.isHidden = false
            purchaseButton.isHidden = false
            
            productsLoadingErrorView.isHidden = true
            return
        }
        
        infoLabel.isHidden = true
        productsStackView.isHidden = true
        redeemButton.isHidden = true
        purchaseButton.isHidden = true
        
        productsLoadingErrorView.isHidden = false
        productsLoadingErrorLabel.text = .ErrorStoreProductsLoading
    }
    
    private func configurePurchaseButton() {
        purchaseButton.setTitleColor(.atButtonText.withAlphaComponent(0.5), for: .disabled)
    }
    
    private func updatePurchaseButton() {
        let isProductSelected = productsStackView.arrangedSubviews.map({$0 as! SDStoreProductView}).contains(where: {$0.state == .selected})
        purchaseButton.isEnabled = isProductSelected
    }
    
    private func clearProductSelection() {
        productsStackView.arrangedSubviews.forEach { view in
            if (view as? SDStoreProductView)?.state == .selected {
                (view as? SDStoreProductView)?.state = .default
            }
        }
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
}

// MARK: - Actions

extension SDCoinsStoreViewController {
    @IBAction private func purchaseButtonPressed(_ sender: Any) {
        guard let selectedProduct else {
            return
        }
        showActivity(true)
        SDStore.shared.buy(product: selectedProduct) { [weak self] result in
            self?.showActivity(false)
            switch result {
                case .cancelled:
                    break
                case .error(let error):
                    self?.showErrorAlert(error: error)
                case .purchased:
                    self?.updateCoinsView()
                    self?.coinsView.animateFilled()
                    self?.dismiss(animated: true, completion: {
                        self?.completion?(true)
                        self?.completion = nil
                    })
            }
        }
    }
    
    @IBAction private func redeemOfferCodeButtonPressed(_ sender: Any) {
        SDStore.shared.showOfferCodeRedeem()
    }
    
    @IBAction private func closeButtonPresed(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.completion?(false)
            self?.completion = nil
        }
    }
}
