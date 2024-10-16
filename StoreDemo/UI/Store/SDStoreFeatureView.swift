//
//  StoreFeatureView.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

class SDStoreFeatureView: UIView {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    var feature: SDStoreFeature? {
        didSet {
            imageView.image = feature?.image
            titleLabel.text = feature?.title
        }
    }
}
