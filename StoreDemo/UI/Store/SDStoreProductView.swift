//
//  StoreProductView.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit
import StoreKit

enum StoreProductViewState {
    case `default`
    case selected
    case disabled
}

class SDStoreProductView: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var checkmarkImageView: UIImageView!
    @IBOutlet private weak var button: UIButton!
    
    var onSelect:(() -> Void)?
    var state: StoreProductViewState = .default {
        didSet {
            updateUI()
        }
    }
    
    var product: Product! {
        didSet {
            updateUI()
        }
    }
    
    var fullPriceProduct: Product? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.borderWidth = 1
        updateUI()
    }
    
    private func updateUI() {
        if let product {
            titleLabel.text = product.displayName
            priceLabel.text = product.displayPrice
            
            var descriptionParts: [String] = [
                product.description
            ]
            if let fullPriceProduct = fullPriceProduct {
                let discount = product.discountInCompareWith(fullPriceProduct)
                let discountFormat = abs(discount.truncatingRemainder(dividingBy: 1)) < 0.2 ? " %.0f" : " %.1f"
                descriptionParts.append(.StoreProductSave + String(format: discountFormat, discount) + "%")
            }
            descriptionLabel.text = descriptionParts.joined(separator: "\n")
            descriptionLabel.isHidden = descriptionParts.isEmpty
        }
        switch state {
            case .default:
                button.isEnabled = true
                layer.borderColor = UIColor.gray.cgColor
                layer.borderWidth = 1
                checkmarkImageView.tintColor = UIColor.gray
                checkmarkImageView.image = UIImage(systemName: "circle")
            case .selected:
                button.isEnabled = true
                layer.borderColor = UIColor.sdStoreSelectedProductTint.cgColor
                layer.borderWidth = 2
            checkmarkImageView.tintColor = UIColor.sdTint
                checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
            case .disabled:
                button.isEnabled = false
                layer.borderColor = UIColor.systemRed.cgColor
                layer.borderWidth = 2
                checkmarkImageView.tintColor = UIColor.systemRed
                checkmarkImageView.image = UIImage(systemName: "circle")
        }
        
    }
    
    @IBAction private func buttonPressed(_ sender: Any) {
        state = .selected
        onSelect?()
    }
}
