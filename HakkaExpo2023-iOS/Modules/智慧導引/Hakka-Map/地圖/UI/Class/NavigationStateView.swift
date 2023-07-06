//
//  NavigationStateView.swift
//  NAVISDK
//
//  Created by Jimmy Zhong on 2019/11/22.
//  Copyright © 2019 omniguider. All rights reserved.
//

import UIKit

protocol NavigationStateDelegate: AnyObject {
    func navStateDidPressStart()
    func navStateDidPressEnd()
    func navStateDidPressSimulate()
}

class NavigationStateView: UIView {
    weak var delegate: NavigationStateDelegate?
    private(set) var viewTopConstraint: CGFloat = 0
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleCenterY: NSLayoutConstraint!
    @IBOutlet weak var endNavigationBtn: UIButton!
    
    func setup(poiModel: OGPointModel?) {
        guard let poi = poiModel else {
            return
        }
        let floorName = NaviUtility.GetFloorName(by: poi.number)
        titleLabel.text = "\(floorName)-\(poi.name)"
    }
    
    func navBtnStart() {
        endNavigationBtn.isHidden = false
    }
    
    func navBtnEnd() {
        endNavigationBtn.isHidden = true
    }
        
    @IBAction func pressEndNaviBtn(_ sender: Any) {
        delegate?.navStateDidPressEnd()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Bundle(for: NavigationStateView.self).loadNibNamed(String(describing: NavigationStateView.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        endNavigationBtn.setTitle("結束導航", for: .normal)
        endNavigationBtn.setBackgroundImage(UIImage(), for: .normal)
        viewTopConstraint = 80 - phoneBottomInset
    }
}
