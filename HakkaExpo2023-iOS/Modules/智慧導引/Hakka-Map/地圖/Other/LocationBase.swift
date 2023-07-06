//
//  LocationBase.swift
//  KSReligionVisitGuide
//
//  Created by Jelico on 2019/6/28.
//  Copyright © 2019 Omniguider. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import IndoorAtlas
import CoreLocation

protocol LocationBaseDelegate: AnyObject {
    func locationInfo(didUpdate location: CLLocation)
    func locationInfo(didEnter identifier: String)
    func locationInfo(didUpdate direction: CLLocationDirection)
}

//Debug
protocol LocationBaseDebugDelegate: AnyObject {
    func locationDebugInfo(didUpdateStatus status: String)
    func locationDebugInfo(with manager: IALocationManager, didUpdateLocations locations: [Any])
    func locationDebugInfo(with manager: IALocationManager, didEnter region: IARegion)
    func locationDebugInfo(with manager: IALocationManager, didExitRegion region: IARegion)
}

class LocationBase: NSObject {
    static let shared = LocationBase()
    weak var delegate: LocationBaseDelegate?
    weak var debugDelegate: LocationBaseDebugDelegate?
    
    private let locManager: CLLocationManager = {
        $0.requestWhenInUseAuthorization()
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.distanceFilter = 5
        $0.startUpdatingHeading()
        return $0
    }(CLLocationManager())

    private(set) var status: String = "" {
        didSet {
            debugDelegate?.locationDebugInfo(didUpdateStatus: status)
        }
    }
    private var isIndoor = false
    private var isLocationEnabled: Bool!
    private var isIAManagerStart = false
    private(set) var IAmanager: IALocationManager! // indoorAtlas LocationManager
    private var indoorTimer = Timer()
    private var goodCertainty = false
    private var goodAccuracy = false
    private var horizontalAccuracy: CLLocationAccuracy!
    private var floorCertainty: IACertainty!
    
    var enteredProjectPlanId: String!
    var coordinate: CLLocationCoordinate2D!
    var location: CLLocation!
    
    func start() {
        if isIAManagerStart {
            return
        }
        self.startLocationBase()
    }
    
    private func startLocationBase() {
        self.startIndoorTimer()
        self.locManager.delegate = self
    }
    
    private func startIndoorTimer() {
        self.status = "Check Data"
        self.indoorTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.determineIndoorStart), userInfo: nil, repeats: true)
    }
    
    @objc private func determineIndoorStart() {
        guard NaviProject.planModels.count > 0 else {
            return
        }
        self.indoorTimer.invalidate()
        // 啟動IndoorAtlas位置管理
        self.indoorManagerStart()
        self.locManager.startUpdatingLocation()
    }
    
    private func indoorManagerStart() {
        // Create IALocationManager and point delegate to receiver
        self.IAmanager = IALocationManager.sharedInstance()
        self.IAmanager.delegate = self
        self.IAmanager.distanceFilter = 0.1

        let kAPIKey = Paras.indoorApiKey
        let kAPISecret = Paras.indoorApiSecret

        // Set IndoorAtlas API key and secret
        self.IAmanager.setApiKey(kAPIKey, andSecret: kAPISecret)

        // Request location updates
        self.IAmanager.startUpdatingLocation() // 更新使用者位置(indoorLocationManager:didUpdateLocations)
        self.isIAManagerStart = true
        self.status = "Start Updating Location"
    }

    private func evaluateCertainty(certainty: IACertainty) -> Bool {
        return (certainty > Paras.standardCertainty) ? true : false
    }


    private func evaluateAccuracy(accuracy: CLLocationAccuracy) -> Bool {
        return (accuracy < Paras.standardAccuracy) ? true : false
    }
}

//MARK: - IALocationManager Delegate
extension LocationBase: IALocationManagerDelegate {
    func indoorLocationManager(_ manager: IALocationManager, didUpdateLocations locations: [Any]) {
        debugDelegate?.locationDebugInfo(with: manager, didUpdateLocations: locations)
        guard
            locations.last != nil,
            let ialoc = locations.last as? IALocation
        else {
            return
        }

        guard
            let floorCertainty = ialoc.floor?.certainty,
            let horizontalAccuracy = ialoc.location?.horizontalAccuracy
        else {
            return
        }

        self.floorCertainty = floorCertainty
        self.horizontalAccuracy = horizontalAccuracy

        self.goodCertainty = self.evaluateCertainty(certainty: floorCertainty)
        self.goodAccuracy = self.evaluateAccuracy(accuracy: horizontalAccuracy)

        guard let loc = ialoc.location else {
            return
        }

        self.location = loc
        self.coordinate = loc.coordinate
        self.delegate?.locationInfo(didUpdate: loc)
    }

    func indoorLocationManager(_ manager: IALocationManager, didEnter region: IARegion) {
        debugDelegate?.locationDebugInfo(with: manager, didEnter: region)
        let planId = region.identifier

        //專案planId才給過
        guard (NaviUtility.IsProjectPlanId(planId: planId) == true) else {return}
        self.delegate?.locationInfo(didEnter: planId)
        self.enteredProjectPlanId = planId
        self.isIndoor = true
    }
    
    func indoorLocationManager(_ manager: IALocationManager, didExitRegion region: IARegion) {
        debugDelegate?.locationDebugInfo(with: manager, didExitRegion: region)
        self.isIndoor = false
    }
}

//MARK: - CLLocationManager Delegate
extension LocationBase: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !isIndoor else {
            return
        }
        location = locations.last
        guard location != nil else {
            return
        }
        coordinate = location.coordinate
        floorCertainty = 0
        horizontalAccuracy = location.horizontalAccuracy
        goodCertainty = evaluateCertainty(certainty: floorCertainty)
        goodAccuracy = evaluateAccuracy(accuracy: horizontalAccuracy)
        delegate?.locationInfo(didUpdate: location)
    }
    
    // 方位角更新代理程式
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard (newHeading.headingAccuracy >= 0) else {
            return
        }

        let theHeading = (newHeading.trueHeading > 0) ? (newHeading.trueHeading) : (newHeading.magneticHeading)
        self.delegate?.locationInfo(didUpdate: theHeading)
    }
    
    // 檢查使用者位置授權，1.若有：執行位置更新 2.若未決：彈出詢問視窗 3.若拒絕：彈出設定視窗
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            //儲存定位服務狀態
            self.isLocationEnabled = false
        }else if status == .notDetermined {
            self.isLocationEnabled = false
            self.locManager.requestWhenInUseAuthorization()
        }else {
            self.isLocationEnabled = true
            //方位角
            if CLLocationManager.headingAvailable() {
                self.locManager.headingFilter = 1 //感應角度:每n度更新一次
                self.locManager.startUpdatingHeading() //開始感應手機方位角(與正北或磁北)
            }
        }
    }
}
