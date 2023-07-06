//
//  NavigationBottomGuideVC.swift
//  NAVISDK
//
//  Created by Dong on 2023/6/28.
//

import UIKit

protocol NavigationBottomGuideVCDelegate {
    func navBottomGuideVCDidPressSimulateBtn()
    func navBottomGuideVCDidPressNavBtn()
}

class NavigationBottomGuideVC: UIViewController {
    //MARK: - Variables
    var delegate: NavigationBottomGuideVCDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: - IBActions
    @IBAction func simulateBtnPressed(_ sender: Any) {
        delegate?.navBottomGuideVCDidPressSimulateBtn()
    }
    
    @IBAction func navBtnPressed(_ sender: Any) {
        delegate?.navBottomGuideVCDidPressNavBtn()
    }
    
    //MARK: - Function
    func setup(with point: OGPointModel) {
        titleLabel.text = point.floorName + "-" + point.name
    }
}
