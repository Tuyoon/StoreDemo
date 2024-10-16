//
//  UIButton+Utils.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

extension UIButton {
    /// Add attributed title with current font.
    func sdSetAttribugedTitle(_ title: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.titleLabel!.font!
        ]
        setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)
    }
}
