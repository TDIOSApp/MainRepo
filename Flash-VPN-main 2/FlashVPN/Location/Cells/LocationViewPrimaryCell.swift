//
//  LocationViewPrimaryCell.swift
//  FlashVPN
//
//  Created by Алексей Трушковский on 13.08.2021.
//

import UIKit

class LocationViewPrimaryCell: UITableViewCell {
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationSignal: UIImageView!
    @IBOutlet weak var back: UIView!
    @IBOutlet weak var LocationIndicator: UIImageView!
    
    var ping = Double.greatestFiniteMagnitude
    func getUsageStat(server: String) {
        if let currentUsage = usage[server] {
            self.ping = currentUsage
            print("ping: \(currentUsage)")
        }
    }
    
    func setupCellIndicator() {
        if ping < 120 {
            markStatus(status: .signal4)
        }
        if ping > 120 && ping < 150{
            markStatus(status: .signal3)
        }
        if ping > 150 && ping < 200 {
            markStatus(status: .signal2)
        }
        if ping > 200 {
            markStatus(status: .signal1)
        }
    }
    
    func markStatus(status: UsageStatus) {
        switch status {
        case .signal4:
            locationSignal.image = UIImage(named: "signal4")
        case .signal3:
            locationSignal.image = UIImage(named: "signal3")
        case .signal2:
            locationSignal.image = UIImage(named: "signal2")
        case .signal1:
            locationSignal.image = UIImage(named: "signal1")
        }
    }
    
    override func layoutSubviews() {
        self.back.clipsToBounds = true
        self.back.layer.cornerRadius = back.layer.frame.height/2
        self.back.layer.borderWidth = 2
        self.back.layer.borderColor = 0x0DB1ED.toColor().cgColor
        self.back.layer.backgroundColor = UIColor.clear.cgColor
    }
}

enum UsageStatus {
    case signal4
    case signal3
    case signal2
    case signal1
}
