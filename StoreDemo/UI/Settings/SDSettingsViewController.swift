//
//  SDSettingsViewController.swift
//  StoreDemo
//
//  Created by Admin
//

import UIKit
//import StoreKit

private enum SDSettingsSection: Int {
    case ui
    
    var title: String? {
        switch self {
            case .ui:
                return .SettingsUI
        }
    }
}

private enum SDSettingsItemType {
    case backgroundColor
    
    var cellIdentifier: String {
        switch self {
            case .backgroundColor:
                return "BackgroundColorCell"
        }
    }
}

class SDSettingsViewController: UITableViewController {
    
    @IBOutlet private weak var premiumInfoLabel: UILabel!
    @IBOutlet private weak var joinPremiumButton: UIButton!
    @IBOutlet private weak var versionLabel: UILabel!
    
    private var items: [SDSettingsSection: [SDSettingsItemType]] = [:]
    
    private let store = SDDIContainer.shared.resolve(SDStore.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        reloadItems()
        
        title = .Settings
        
        joinPremiumButton.sdSetAttribugedTitle(.PremiumAction)
        
        let version = Bundle.main.versionString ?? ""
        versionLabel.text = .Version + ": " + version
        updatePremiumUI()
        NotificationCenter.default.addObserver(self, selector: #selector(storePremiumStateChangedNotification), name: .SDStorePremiumStateChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[SDSettingsSection(rawValue: section)!]!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SDSettingsSection(rawValue: section)!.title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[SDSettingsSection(rawValue: indexPath.section)!]![indexPath.row]
        switch item {
            case .backgroundColor:
                let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier, for: indexPath)
                return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Private Methods

extension SDSettingsViewController {
    
    private func reloadItems() {
        items[.ui] = [.backgroundColor]
    }
    
    private func openStore() {
        guard let storeViewController = storyboard?.instantiateViewController(withIdentifier: "PremiumStoreNavigationController") else {
            return
        }
        navigationController?.present(storeViewController, animated: true)
    }
}

// MARK: - Premium / App

extension SDSettingsViewController {
    @IBAction private func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func joinPremiumButtonPressed(_ sender: Any) {
        openStore()
    }
    
    @objc
    private func storePremiumStateChangedNotification(_ notification: Notification) {
        updatePremiumUI()
    }
    
    private func updatePremiumUI() {
        if store.hasPremium {
            joinPremiumButton.isHidden = true
            let state = store.state
            switch state {
                case .none:
                    break
                case .subscribed(let date):
                    premiumInfoLabel.text = String(format: .PremiumStoreSubscriptionActiveFormat, SDDateFormatters.standardString(from: date))
                case .expired(date: _):
                    break
            }
            premiumInfoLabel.isHidden = false
            return
        }
        
        premiumInfoLabel.isHidden = true
        joinPremiumButton.isHidden = false
    }
}
