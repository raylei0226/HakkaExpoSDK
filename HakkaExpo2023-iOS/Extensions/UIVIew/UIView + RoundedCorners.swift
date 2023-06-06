//
//  UIView + RoundedCorners.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/5.
//

import UIKit

extension UIView {
    func addRoundCorners(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
