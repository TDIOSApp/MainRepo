//
//  CustomButton.swift
//  Neo Vpn
//
//  Created by Алексей Трушковский on 19.07.2021.
//

import UIKit

extension Int {
    func toColor() -> UIColor {
        return UIColor(red: ((CGFloat)((self & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((self & 0x00FF00) >> 8))/255.0, blue: ((CGFloat)((self & 0x0000FF)))/255.0, alpha: 1.0)
    }
}

extension UIView {
    func applyGradient(colors: [CGColor]) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 10

        gradientLayer.shadowColor = UIColor.darkGray.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayer.shadowRadius = 5.0
        gradientLayer.shadowOpacity = 0.3
        gradientLayer.masksToBounds = false

        self.layer.insertSublayer(gradientLayer, at: 0)
//        self.contentVerticalAlignment = .center
//        self.setTitleColor(UIColor.white, for: .normal)
//        self.titleLabel?.font = .systemFont(ofSize: 20, weight: .light)
//        self.setTitleColor(UIColor(red: 1.0/255.0, green: 26.0/255.0, blue: 57.0/255.0, alpha: 1.0), for: .normal)
    }
}
