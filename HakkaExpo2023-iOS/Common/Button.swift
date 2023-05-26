//
//  Button.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/25.
//

import UIKit

class ButtonWithRightImage: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
    }
    
    private func commonInit() {
           setTitleEdgeInsetsForImageOnRight()
           setContentHorizontalAlignmentForLeftAlignment()
       }
    
    private func setTitleEdgeInsetsForImageOnRight() {
           titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageView!.frame.size.width, bottom: 0, right: imageView!.frame.size.width)
           imageEdgeInsets = UIEdgeInsets(top: 0, left: titleLabel!.frame.size.width, bottom: 0, right: -titleLabel!.frame.size.width)
       }
       
       private func setContentHorizontalAlignmentForLeftAlignment() {
           contentHorizontalAlignment = .left
       }
}

