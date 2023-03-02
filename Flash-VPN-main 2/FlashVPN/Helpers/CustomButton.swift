//
//  CustomButton.swift
//  Neo Vpn
//
//  Created by Алексей Трушковский on 19.07.2021.
//

import UIKit

class CustomButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.layer.frame.height/5;
        self.backgroundColor = .white
    }
}

import UIKit

class GoldButton: UIButton {
    
    static func UIColorFromRGB(_ rgbValue: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0x00FF00) >> 8))/255.0, blue: ((CGFloat)((rgbValue & 0x0000FF)))/255.0, alpha: 1.0)
    }
}
