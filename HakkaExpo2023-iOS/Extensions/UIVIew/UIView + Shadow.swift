//
//  UIView + Shadow.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/12.
//

import UIKit

extension UIView {

        func dropShadow(color: UIColor = UIColor.black,
                       opacity: Float = 0.5,
                       offset: CGSize = CGSize(width: 0, height: 2),
                       radius: CGFloat = 4) {
            layer.shadowColor = color.cgColor
            layer.shadowOpacity = opacity
            layer.shadowOffset = offset
            layer.shadowRadius = radius
            layer.masksToBounds = false
        }
    }
