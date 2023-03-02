//
//  LocationViewPrimaryCell.swift
//  FlashVPN
//
//  Created by Алексей Трушковский on 13.08.2021.
//

import UIKit

class SettingsCell: UITableViewCell {
    @IBOutlet weak var settingsTitle: UILabel!
    @IBOutlet weak var back: UIView!
    
    override func layoutSubviews() {
        self.back.clipsToBounds = true
        self.back.layer.cornerRadius = back.layer.frame.height/5
        self.back.layer.borderWidth = 2
        self.back.layer.borderColor = 0x0DB1ED.toColor().cgColor
        self.back.layer.backgroundColor = UIColor.clear.cgColor
    }
}
