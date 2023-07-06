//
//  NavigationSearchCell.swift
//  NAVISDK
//
//  Created by 李東儒 on 2020/6/16.
//  Copyright © 2020 omniguider. All rights reserved.
//

import UIKit

class NavigationSearchCell: UITableViewCell {
    @IBOutlet weak var navImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLab: UILabel!
    @IBOutlet weak var disclureIcon: UIImageView!
    @IBOutlet weak var lineView: UIView!

    func setup(with point: OGPointModel) {
        distanceLab.isHidden = false
        disclureIcon.isHidden = false
        lineView.isHidden = false

        let floorName = NaviUtility.GetFloorName(by: point.number)
        titleLabel.text = "\(floorName)-\(point.name)"
    
        if let distance = point.distance {
            distanceLab.text = "\(distance)m"
        }else {
            distanceLab.text = nil
        }
    }
    
    func setup(with image: UIImage, title: String) {
        distanceLab.isHidden = true
        disclureIcon.isHidden = true
        lineView.isHidden = true
        navImageView.image = image
        titleLabel.text = title
    }
}
