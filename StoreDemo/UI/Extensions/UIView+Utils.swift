//
//  UIView+Utils.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)!.first as! T
    }
}

extension UIView {
    func addShadow(color: UIColor,
                   shadowOffset: CGSize = CGSize(width: 0, height: 10),
                   shadowOpacity: Float = 1.0,
                   shadowRadius: CGFloat = 5.0
    ) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
    }
    
    func animateFilled() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat]) {
            let transform = self.transform
            self.transform = transform.scaledBy(x: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.transform = transform
            }
        }
    }
}
