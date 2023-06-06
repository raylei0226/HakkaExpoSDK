//
//  UIImage + Bundle.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/6.
//

import UIKit

extension UIImage {
    convenience init?(named name: String, bundle: Bundle) {
        self.init(named: name, in: bundle, compatibleWith: nil)
    }
}

