//
//  SDSwitchTableViewCell.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

protocol SDSwitchTableViewCellDelegate: AnyObject {
    func switchTableViewCell(_ cell: SDSwitchTableViewCell, didChangeValue value: Bool)
}

class SDSwitchTableViewCell: UITableViewCell {

    private(set) weak var delegate: SDSwitchTableViewCellDelegate?
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
    }
    
    func configure(delegate: SDSwitchTableViewCellDelegate, value: Bool, name: String) {
        self.delegate = delegate
        valueSwitch.isOn = value
        titleLabel.text = name
    }
    
    @IBAction private func switchValueChanged(_ sender: UISwitch) {
        delegate?.switchTableViewCell(self, didChangeValue: sender.isOn)
    }
}
