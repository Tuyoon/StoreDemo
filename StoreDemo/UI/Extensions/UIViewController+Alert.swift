//
//  UIViewController+Alert.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

extension UIViewController {
    
    /// Show alert.
    /// Cancellable alert has destructive main action button.
    func showAlert(title: String, destructive: Bool = false, completion:(() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        if destructive {
            alert.addAction(UIAlertAction(title: .AlertCancel, style: .cancel))
        }
        alert.addAction(UIAlertAction(title: .AlertOk, style: ( destructive ? .destructive : .default), handler: { action in
            completion?()
        }))
        present(alert, animated: true)
    }
    
    /// Show alert.
    func showAlert(title: String,
                   message: String? = nil,
                   actionName: String = .AlertOk,
                   cancellable: Bool = false,
                   completion:((_ isCancelled: Bool) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if cancellable {
            alert.addAction(UIAlertAction(title: .AlertCancel, style: .cancel, handler: { action in
                completion?(true)
            }))
        }
        alert.addAction(UIAlertAction(title: actionName, style: .default, handler: { action in
            completion?(false)
        }))
        present(alert, animated: true)
    }

    /// Show error.
    func showErrorAlert(error: Error) {
        let alert = UIAlertController(title: .AlertError, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: .AlertOk, style: .default))
        present(alert, animated: true)
    }
}
