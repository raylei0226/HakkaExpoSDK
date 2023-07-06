//
//  NavigationPresenter.swift
//  NAVISDK
//
//  Created by Jimmy Zhong on 2019/11/22.
//  Copyright © 2019 omniguider. All rights reserved.
//

import Foundation
import GoogleMaps
import UIKit

protocol NavigationPresenterDelegate: AnyObject {
    func navPresenter(didLoad routeArray: [[String : Any]])
    func navPresenter(didUpdate title: String, pressedBtnType: NavigationPresenter.PressedBtnType, navigationType: NavigationPresenter.NavigationType)
    func navPresenter(didUpdateBtnTitle beginTitle: String, targetPoiModel: OGPointModel)
    func navPresenter(showNearbyPoi poi: OGPointModel)
}

class NavigationPresenter {
    weak var delegate: NavigationPresenterDelegate?

    enum NavigationType {case userLocation, poiLocation, anyLocation}
    enum PressedBtnType {case beginPositionBtn, targetPositionBtn, none}
    
    private var pressedBtnType = PressedBtnType.none
    private var beginLocation: CLLocationCoordinate2D?
    private var targetLocation: CLLocationCoordinate2D?
    private var targetName = ""
    private var targetPoint: OGPointModel?
    
    var currentPlaceText = "當前位置"
    var anyPlaceText = "任意位置"
    var dispatchGroup: DispatchGroup?
    let projectColor: UIColor = UIColor(named: "hakkaColor", in: Configs.Bunlde(), compatibleWith: nil)!
    
    func setBeginNameDefault() {
        GlobalState.beginName = currentPlaceText
    }
    
    func getNaviRouteXyAPI(from userFloor: String, beginCoordinate: CLLocationCoordinate2D, priority: String, endPoint: OGPointModel, dispatchGroup: DispatchGroup?) {
        self.dispatchGroup = dispatchGroup
        let parameterDic = NaviUtility.GetRouteXyParameters(by: userFloor, beginCoordinate: beginCoordinate, priority: priority, poiModel: endPoint)
        let parameterString = NaviUtility.ParameterString(parameters: parameterDic, method: .get)
        let apiUrlString = NaviUtility.GetNaviRouteXyAPI + "?" + parameterString
        
        HTTPSClient().getData(apiUrlString, completion: {Datas in
            self.didHandleRouteData(datas: Datas)
        })
    }
    
    func getNaviNearbyTypeAPI(from userFloor: String, coordinate: CLLocationCoordinate2D, type: NearbyType) {
        let parameterDic = NaviUtility.GetNearbyParameters(by: userFloor, userCoordinate: coordinate, type: type.rawValue)
        let parameterString = NaviUtility.ParameterString(parameters: parameterDic, method: .get)
        let apiUrlString = NaviUtility.GetNaviNearbyAPI + "&" + parameterString
        
        HTTPSClient().getData(apiUrlString, completion: {Datas in
            self.didHandleRouteData(datas: Datas)
        })
    }
    
    func didHandleRouteData(datas: Data?) {
        guard
            let data = datas,
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
        else {
            return
        }
                    
        let routeArray = jsonData["data"] as? [[String: Any]] ?? []

        if routeArray.isEmpty {
            let err = jsonData["error_message"]  as? String ?? ""
            let message = "沒有路線\n"  + err
            NaviUtility.ShowAlert(message)
            return
        }
                            
        NaviUtility.NotificationPost(name: .readyRouteData)
        
        DispatchQueue.main.async {
            //快速導引
            if GlobalState.nearbyType != nil {
                let nearbyPoi = NaviUtility.RetrieveNearbyPoi(routeArray)
                GlobalState.endPoi = nearbyPoi
                self.delegate?.navPresenter(showNearbyPoi: nearbyPoi)
            }
                        
            self.delegate?.navPresenter(didLoad: routeArray)
            self.delegate?.navPresenter(didUpdateBtnTitle: GlobalState.beginName, targetPoiModel: GlobalState.endPoi)
        }
        
        (self.dispatchGroup != nil) ? self.dispatchGroup!.leave() : nil
    }
    
    
    //Position Button Pressed
    func didPositionBtnPressed(with pressedType: PressedBtnType) {
        pressedBtnType = pressedType
    }
    
    
    func renewInfo(_ point: OGPointModel?, _ coordinate: CLLocationCoordinate2D?, type: NavigationPresenter.NavigationType) {
        if pressedBtnType == .targetPositionBtn {
            if point != nil {
                self.targetPoint = point
            }
        }else if pressedBtnType == .beginPositionBtn {
            if coordinate != nil {
                beginLocation = coordinate
            }
        }
        
        var beginName: String {
            switch type {
            case .poiLocation:
                return (point!.name)
            case .userLocation:
                return currentPlaceText
            case .anyLocation:
                return anyPlaceText
            }
        }
        
        delegate?.navPresenter(didUpdate: beginName, pressedBtnType: pressedBtnType, navigationType: type)
        
        let coor = (coordinate != nil) ? coordinate : (CLLocationCoordinate2DMake(point!.lat, point!.lng))
        updateBeginOrTargetInfo(with: coor!, name: beginName)
        
        pressedBtnType = .none
    }
    
    private func updateBeginOrTargetInfo(with coordinate: CLLocationCoordinate2D, name: String) {
        switch pressedBtnType {
        case .beginPositionBtn:
            self.beginLocation = coordinate
            GlobalState.beginName = name
        case .targetPositionBtn:
            self.targetLocation = coordinate
            self.targetName = name
        case .none:
            break
        }
    }
        
    //有定位版本
    func startSmartGuider() {
        guard (LocationBase.shared.coordinate != nil) else {
            NaviUtility.ShowAlert("無位置資訊")
            return
        }
    }
    
    func endSmartGuider(completion: ((Bool) -> Void) = {_ in}) {
        
    }

    
    func unSelectAll(_ aacCategoryBtns: [UIButton]) {
        aacCategoryBtns.forEach({btn in
            let titleColor = self.projectColor
            btn.setTitleColor(titleColor, for: .normal)
            btn.backgroundColor = .white
        })
    }
    
    func select(at index: Int, _ aacCategoryBtns: [UIButton]) {
        aacCategoryBtns[index].setTitleColor(.white, for: .normal)
        aacCategoryBtns[index].backgroundColor = self.projectColor
    }

    func unSelect(at index: Int, _ aacCategoryBtns: [UIButton]) {
        aacCategoryBtns[index].setTitleColor(self.projectColor, for: .normal)
        aacCategoryBtns[index].backgroundColor = .white
    }
}
