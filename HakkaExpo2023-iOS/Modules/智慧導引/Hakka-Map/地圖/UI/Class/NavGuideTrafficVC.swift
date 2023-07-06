//
//  NavGuideTrafficVC.swift
//  NAVISDK
//
//  Created by Jimmy Zhong on 2019/11/25.
//  Copyright © 2019 omniguider. All rights reserved.
//

import UIKit
import CoreLocation

protocol NavGuideTrafficDelegate: AnyObject {
    func guideTraffic(didPressedSwitchBtn mode: RouteOrderMode)
    func guideTrafficStartSearchVC(with pressedBtnType: NavigationPresenter.PressedBtnType, _ displayUserLocation: Bool)
    func guideTrafficDidPressSimulateBtn()
    func guideTrafficDidPressNavBtn()
    func guideTrafficDidChoosePriority(tag: Int)
}

class NavGuideTrafficVC: UIViewController {
    weak var delegate: NavGuideTrafficDelegate?
    
    @IBOutlet weak var normalRouteBtn: UIButton!
    @IBOutlet weak var accessibilityBtn: UIButton!
    @IBOutlet weak var beginPositionBtn: UIButton!
    @IBOutlet weak var targetPositionBtn: UIButton!
    @IBOutlet weak var positionStackView: UIStackView!
    @IBOutlet weak var upDownBtn: UIButton!
    @IBOutlet weak var beginDotIcon: UIImageView!
    @IBOutlet weak var endDotIcon: UIImageView!
    
    var currentNavType = NavigationPresenter.NavigationType.userLocation
    var targetNavType = NavigationPresenter.NavigationType.poiLocation
    var routeOrderMode: RouteOrderMode = .normal

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViews()
        self.defaultPriorityRoute()
    }
    
    private func initViews() {
        //若北市府：專用UI
        self.setupTaipeiUI(NaviProject.isTaipeiProject)
    }
    
    
    func setupTaipeiUI(_ isTaipei: Bool) {
        let upDownImage = isTaipei ? (NAVIAsset.upDownSwitch02.img) : (NAVIAsset.upDownSwitch01.img)
        let beginDotImage = isTaipei ? (NAVIAsset.beginDot02.img) : (NAVIAsset.beginDot01.img)
        let endDotImage = isTaipei ? (NAVIAsset.endDot02.img) : (NAVIAsset.endDot01.img)
        self.upDownBtn.setImage(upDownImage, for: .normal)
        self.beginDotIcon.image = beginDotImage
        self.endDotIcon.image = endDotImage
    }

    func defaultPriorityRoute() {
        self.changeRouteBtn(tag: 0)
        self.delegate?.guideTrafficDidChoosePriority(tag: 0)
    }
    
    
    func changeRouteBtn(tag: Int) {
        let pickedColor = NaviProject.color
        let unPickedColor = UIColor.clear
        let pickedTextColor = UIColor.white
        let unPickedTextColor = NaviProject.color
        
        self.normalRouteBtn.borderColor = NaviProject.color
        self.accessibilityBtn.borderColor = NaviProject.color

        self.normalRouteBtn.backgroundColor = (tag == 0) ? pickedColor : unPickedColor
        self.normalRouteBtn.borderWidth = (tag == 0) ? 0 : 1
        
        self.accessibilityBtn.backgroundColor = (tag == 1) ? pickedColor : unPickedColor
        self.accessibilityBtn.borderWidth = (tag == 1) ? 0 : 1
        
        self.normalRouteBtn.setTitleColor((tag == 0) ? (pickedTextColor) : (unPickedTextColor), for: .normal)
        self.accessibilityBtn.setTitleColor((tag == 1) ? (pickedTextColor) : (unPickedTextColor), for: .normal)
    }

    func updateBtnTitle(to currentTitle: String, targetPoiModel: OGPointModel) {
        beginPositionBtn.setTitle(" \(currentTitle)", for: .normal)
        let floorName = NaviUtility.GetFloorName(by: targetPoiModel.number)
        let poiName = targetPoiModel.name
        targetPositionBtn.setTitle("\(floorName)-\(poiName)", for: .normal)
    }
    
    private func calculateTime(_ minute: Int) -> String {
        if minute < 60 {
            return "\(minute) \("Minute")"
        }
        if minute % 60 == 0 {
            return "\(minute / 60) \("Hour")"
        }
        return "\(minute / 60) \("Hour") \(minute % 60) \("Minute")"
    }
    
    @IBAction func chooseRoutePriority(_ sender: UIButton) {
        self.changeRouteBtn(tag: sender.tag)
        self.delegate?.guideTrafficDidChoosePriority(tag: sender.tag)
    }
    
    @IBAction func pressBeginPositionBtn(_ sender: Any) {
        startSearchMode(with: .beginPositionBtn)
    }
    
    @IBAction func targetPositionBtnPressed(_ sender: Any) {
        
    }
    
    @IBAction func pressSwitchBtn(_ sender: Any) {
        self.routeOrderMode = (self.routeOrderMode == .normal) ? .reversed : .normal
        self.shiftPositionOrder(mode: self.routeOrderMode)
    }
    
    func shiftPositionOrder(mode: RouteOrderMode) {
        self.shiftUI(by: self.routeOrderMode)
        self.delegate?.guideTraffic(didPressedSwitchBtn: self.routeOrderMode)
    }
    
    func setDefaultRouteOrderMode() {
        self.routeOrderMode = .normal
        self.shiftPositionOrder(mode: self.routeOrderMode)
    }
    
    func shiftUI(by routeOrderMode: RouteOrderMode) {
        let animate = UIViewPropertyAnimator(duration: 0.3, curve: .linear, animations: {
            self.positionStackView.removeFullyAllArrangedSubviews()
            self.positionStackView.addArrangedSubview((routeOrderMode == .reversed) ? self.targetPositionBtn : self.beginPositionBtn)
            self.positionStackView.addArrangedSubview((routeOrderMode == .reversed) ? self.beginPositionBtn : self.targetPositionBtn)
            self.view.layoutIfNeeded()
        })
        animate.startAnimation()
    }
    
    @IBAction func pressSimulateBtn(_ sender: UIButton) {
        self.delegate?.guideTrafficDidPressSimulateBtn()
    }
    
    @IBAction func pressNavBtn(_ sender: UIButton) {
        NaviUtility.checkIsInProjectRegion(completion: {isInProjectRegion,coordinate in
            if (isInProjectRegion == true) || (NaviUtility.ManualSimulateMode == true) {
                self.delegate?.guideTrafficDidPressNavBtn()
                return
            }else {
                NaviUtility.ShowConfirmAlert("您不在場域", confirm: "確認")
            }
        })
    }
    
    private func startSearchMode(with pressedBtnType: NavigationPresenter.PressedBtnType) {
        if currentNavType != .userLocation && targetNavType != .userLocation {
            delegate?.guideTrafficStartSearchVC(with: pressedBtnType, true)
        }else {
            delegate?.guideTrafficStartSearchVC(with: pressedBtnType, false)
        }
    }
    
    func updateBtnInfo(with title: String, pressedBtnType: NavigationPresenter.PressedBtnType, navigationType: NavigationPresenter.NavigationType) {
        switch pressedBtnType {
        case .beginPositionBtn:
            beginPositionBtn.setTitle(" \(title)", for: .normal)
            currentNavType = navigationType
        case .targetPositionBtn:
            targetPositionBtn.setTitle(" \(title)", for: .normal)
            targetNavType = navigationType
        case .none:
            break
        }
    }
}
