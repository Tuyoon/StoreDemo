//
//  SDBackgroundColorTableViewCell.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

class SDBackgroundColorTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var tableColorTitleLabel: UILabel!
    @IBOutlet private weak var resetTableColorButton: UIButton!
    @IBOutlet private weak var tableColorWell: UIColorWell!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tableColorTitleLabel.text = .SettingsUIBackgroundColor
        resetTableColorButton.setTitle(.SettingsUIColorReset, for: .normal)
        tableColorWell.selectedColor = SDSettings.backgroundColor
        tableColorWell.addTarget(self, action: #selector(tableColorChanged), for: .valueChanged)
    }
    
    @IBAction private func resetBackgroundColorButtonPressed(_ sender: UIButton) {
        SDSettings.backgroundColor = SDColor.defaultBackgroundColor
        tableColorWell.selectedColor = SDColor.defaultBackgroundColor
    }
    
    @objc
    private func tableColorChanged(_ sender: UIColorWell) {
        guard let color = sender.selectedColor else {
            return
        }
        SDSettings.backgroundColor = color
    }
}
