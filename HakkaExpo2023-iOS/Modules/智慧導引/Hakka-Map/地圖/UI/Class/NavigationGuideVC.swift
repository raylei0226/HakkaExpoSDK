//
//  NavigationGuideVC.swift
//  NAVISDK
//
//  Created by Jimmy Zhong on 2019/11/25.
//  Copyright © 2019 omniguider. All rights reserved.
//

import UIKit

protocol NavigationGuideDelegate: AnyObject {
    func navGuide(didPressedSwitchBtn routeMode: RouteOrderMode)
    func navGuideStartSearchVC(with pressedBtnType: NavigationPresenter.PressedBtnType, _ displayUserLocation: Bool)
    func guideTrafficDidPressSimulateBtn()
    func guideTrafficDidPressNavBtn()
    func guideTrafficDidChoosePriority(tag: Int)
}

class NavigationGuideVC: UIViewController, NavGuideTrafficDelegate {
    weak var delegate: NavigationGuideDelegate?
    
    private let viewHeight: CGFloat = 160
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var trafficViewHeight: NSLayoutConstraint!    
    @IBOutlet weak var trafficViewBottom: NSLayoutConstraint!
    @IBOutlet weak var infoViewBottom: NSLayoutConstraint!

    var trafficVC: NavGuideTrafficVC!
    var infoVC: NavGuideInfoVC!
    
    private var isStartSearch = false

    override func viewDidLoad() {
        super.viewDidLoad()
        updateToTraffic(dispatchGroup: nil)
    }
    
    func endSearch() {
        isStartSearch = false
    }
    
    func didUpdateBtnTitle(to currentTitle: String, targetPoiModel: OGPointModel) {
        trafficVC.updateBtnTitle(to: currentTitle, targetPoiModel: targetPoiModel)
    }
    
    func updateToTraffic(dispatchGroup: DispatchGroup?) {
        UIView.animate(withDuration: 0.5, animations: {
                        self.hideInfoView()
                        self.view.layoutSubviews()
        }, completion: {_ in
            self.trafficViewBottom.constant = 0
            guard
                dispatchGroup != nil,
                NaviUtility.DispatchGroupCount(group: dispatchGroup!) != nil
            else {
                return
            }
            dispatchGroup!.leave()
        })
    }
    
    func hideInfoView() {
        infoViewBottom.constant = self.infoView.frame.height
    }
    
    func showInfoView() {
        infoViewBottom.constant = 0
    }

    //MARK: Nav. Guide Traffic Delegate
    func guideTraffic(didPressedSwitchBtn routeMode: RouteOrderMode) {
        self.delegate?.navGuide(didPressedSwitchBtn: routeMode)
    }

    func guideTrafficStartSearchVC(with pressedBtnType: NavigationPresenter.PressedBtnType, _ displayUserLocation: Bool) {
        isStartSearch = true
        delegate?.navGuideStartSearchVC(with: pressedBtnType, displayUserLocation)
    }
    
    func guideTrafficDidPressSimulateBtn() {
        self.delegate?.guideTrafficDidPressSimulateBtn()
    }
    
    func guideTrafficDidPressNavBtn() {
        self.delegate?.guideTrafficDidPressNavBtn()
    }
    
    func guideTrafficDidChoosePriority(tag: Int) {
        self.delegate?.guideTrafficDidChoosePriority(tag: tag)
    }

    //MARK: - Info VC
    func updateToInfo() {
        self.showInfoView()
        trafficViewBottom.constant = self.trafficViewHeight.constant
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutSubviews()
        })
    }
    
    func update(distance: Double, and direction: NavPoint.Direction) {
        infoVC.setup(distance: distance, and: direction)
    }
    
    func updateTrafficVCBtnInfo(with title:String, pressedBtnType: NavigationPresenter.PressedBtnType, navigationType: NavigationPresenter.NavigationType) {
        trafficVC.updateBtnInfo(with: title, pressedBtnType: pressedBtnType, navigationType: navigationType)
    }

    //MARK: - Initialization
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "traffic" {
            trafficVC = (segue.destination as! NavGuideTrafficVC)
            trafficVC.delegate = self
        }else if segue.identifier == "info" {
            infoVC = (segue.destination as! NavGuideInfoVC)
        }
    }
}
