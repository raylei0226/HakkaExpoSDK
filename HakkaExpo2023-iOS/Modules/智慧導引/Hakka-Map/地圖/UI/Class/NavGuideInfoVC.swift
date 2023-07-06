//
//  NavGuideInfoVC.swift
//  NAVISDK
//
//  Created by Jimmy Zhong on 2019/11/25.
//  Copyright © 2019 omniguider. All rights reserved.
//

import UIKit

class NavGuideInfoVC: UIViewController {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var infoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    func initialize() {
        distanceLabel.text = "0.0 M"
        directionLabel.text = ""
        arrowImageView.image = nil
    }
    
    func setupUI() {
        self.infoView.layer.addShadow()
    }
    
    func setup(distance: Double, and direction: NavPoint.Direction) {
        let distanceStr = String(format: "%.1f", distance)
        
        switch direction {
        case .left:
            let directionStr = "左轉"
            self.distanceLabel.text = "\(distanceStr)公尺後\(directionStr)"
            arrowImageView.image = NAVIAsset.arrow_left.img
        case .slightLeft:
            let directionStr = "微靠左"
            self.distanceLabel.text = "\(directionStr)"
            arrowImageView.image = NAVIAsset.arrow_slightLeft.img
        case .right:
            let directionStr = "右轉"
            self.distanceLabel.text = "\(distanceStr)公尺後\(directionStr)"
            arrowImageView.image = NAVIAsset.arrow_right.img
        case .slightRight:
            let directionStr = "微靠右"
            self.distanceLabel.text = directionStr
            arrowImageView.image = NAVIAsset.arrow_slightRight.img
        case .alongStraight:
            let directionStr = "沿著路線行走"
            self.distanceLabel.text = directionStr
            arrowImageView.image = NAVIAsset.arrow_straight.img
        case .end:
            let directionStr = "抵達終點"
            self.distanceLabel.text = directionStr
            arrowImageView.image = NAVIAsset.arrow_straight.img
        }
    }
}
