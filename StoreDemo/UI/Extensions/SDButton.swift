//
//  SDButton.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

class SDButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5))
        
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }
    
    @objc
    private func animateDown(sender: UIButton) {
        animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95))
    }
    
    @objc
    private func animateUp(sender: UIButton) {
        animate(sender, transform: .identity)
    }
    
    private func animate(_ button: UIButton, transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 1.5,
                       initialSpringVelocity: 3,
                       options: [.curveEaseInOut],
                       animations: {
            button.transform = transform
        }, completion: nil)
    }
}
