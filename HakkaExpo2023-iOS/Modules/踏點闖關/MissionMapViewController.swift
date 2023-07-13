//
//  MissionMapViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/30.
//

import UIKit
import GoogleMaps
import CoreLocation

class MissionMapViewController: BasicViewController {
    
    var isFinding: Bool = false
    
    var gridInfoData: GridInfoData?
    
    var gridData: NineGrid?
    
    var mapData: MapDataType?
    
    var tileLayer: GMSTileLayer?
    
    var markers: [GMSMarker] = []
    
    var markerIndex: Int?
    
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var missionTipsLayerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "關卡地圖"
        missionTipsLayerView.layer.cornerRadius = 12
        missionTipsLayerView.dropShadow()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        mapView.mapStyle = try! GMSMapStyle(jsonString: Configs.kMapStyle)
        mapView.isMyLocationEnabled = true
        missionTipsLayerView.isHidden = isFinding ? false : true
        
        if let data = gridData {
            setupUI(.nineGrid(data: data))
            setupMarker(.nineGrid(data: data))
            BLEManager.instance.delegate = self
            BLEManager.instance.startScan()
        } else if let data = gridInfoData {
            setupUI(.gridInfo(data: data))
            setupMarker(.gridInfo(data: data))
        }
        
        RestAPI.shared.getFloor(buildingID: 4) { data in
            print("Floor:\(String(describing: data))")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        BLEManager.instance.stopScan()
    }
    
    
    private func setupUI(_ mapData: MapDataType) {
        
        switch mapData {
            
        case .gridInfo(data: let data):
            let lat = data?.nineGrid?.first?.beacon?.lat
            let lng = data?.nineGrid?.first?.beacon?.lng
            let camera = GMSCameraPosition(latitude: Double(lat!)!, longitude: Double(lng!)!, zoom: 18)
            mapView.camera = camera
            
        case .nineGrid(data: let data):
            let lat = data?.beacon?.lat
            let lng = data?.beacon?.lng
            let camera = GMSCameraPosition(latitude: Double(lat!)!, longitude: Double(lng!)!, zoom: 18)
            mapView.camera = camera
        }
    }
    
    private func setupMarker(_ mapData: MapDataType) {
        
        switch mapData {
            
        case .gridInfo(data: let data):
            for (index, coordinate) in data!.nineGrid!.enumerated() {
                let lat = Double((coordinate.beacon?.lat)!)
                let lng = Double((coordinate.beacon?.lng)!)
                let position = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
                let marker = GMSMarker()
                let bundle = Bundle(for: MissionMapViewController.self)
                marker.position = position
                marker.map = mapView
                markers.append(marker)
                marker.icon = UIImage(named: "checkPoint\(index + 1)", bundle: bundle)
            }
        case .nineGrid(data: let data):
            let lat = Double((data?.beacon?.lat)!)
            let lng = Double((data?.beacon?.lng)!)
            let position = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
            let marker = GMSMarker()
            let bundle = Bundle(for: MissionMapViewController.self)
            marker.position = position
            marker.map = mapView
            marker.icon = UIImage(named: "checkPoint\(markerIndex ?? 1)", bundle: bundle)
            marker.isTappable = false
        }
    }
    
    private func addTileLayer(planID: String) {
        
        let urls: GMSTileURLConstructor = { (x, y, zoom) in
            let url = "https://omnig-anyplace.omniguider.com/\(planID)/\(zoom)/\(x)/\(y).png"
            
            return URL(string: url)
        }
        mapView.clear()
        self.tileLayer = GMSURLTileLayer(urlConstructor: urls)
        self.tileLayer?.zIndex = 100
        self.tileLayer?.map = mapView
    }
}

extension MissionMapViewController: BLEManagerDelegate {
    
    func didDiscoverServiceData(_ hwid: String) {
        
        print("發現Beacon : \(hwid)")
        
        guard let gridData = gridData else { return }
        
        if hwid.lowercased() == gridData.beacon?.hwid {
            
            if gridData.passMethod == LevelType.qa.rawValue {
                MissionAlertView.instance.configure(with: .arrival)
                BLEManager.instance.stopScan()
                MissionAlertView.instance.onClickConfirm = {
                    self.configAlertAction(.arrival)
                }
            } else if gridData.passMethod == LevelType.touchdown.rawValue {
                guard let mID = UserDefaults.standard.value(forKey: K.missionID) as? String, let gID = gridData.id else {
                    HudManager.shared.showError(withMessage: "取得關卡資訊失敗。請重新嘗試")
                    return
                }
                
                MissionAlertView.instance.configure(with: .touchdown)
                BLEManager.instance.stopScan()
                MissionAlertView.instance.onClickConfirm = {
                    HudManager.shared.showProgress()
                    RestAPI.shared.getMissionComplete(mID, gID) { data in
                        print("結果:\(String(describing: data))")
                        self.configAlertAction(.touchdown)
                        HudManager.shared.hide()
                    }
                }
            }
        }
    }
    
    func configAlertAction(_ type: MLAlertViewType) {
        
        MissionAlertView.instance.mlParentView.removeFromSuperview()
        
        if type == .arrival, let gridData = gridData {
            Router.shared.navigationToQusetion(self, data: gridData)
        } else {
            Router.shared.backToMissionLevel(self)
        }
    }
}

extension MissionMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            // 開始更新使用者位置
            locationManager.startUpdatingLocation()
        }
    }
    
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        guard let location = locations.first else { return }
    //        let userLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.latitude)
    //        let bundle = Bundle(for: MissionMapViewController.self)
    //        let marker = GMSMarker(position: userLocation)
    //        marker.icon = UIImage(named: "userLocation", bundle: bundle)
    //        marker.map = mapView
    //
    //    }
}

extension MissionMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        VibrationFeedbackManager.shared.playVibration()
        
        if let data = gridData {
            Router.shared.navigationToAwardInfo(self, infoType: .levelIntroduction, gridData: data, ticketData: nil, numberIndex: markerIndex)
        } else {
            for (index, element) in markers.enumerated() {
                if marker == element {
                    if let data = gridInfoData?.nineGrid?[index] {
                        Router.shared.navigationToAwardInfo(self, infoType: .levelIntroduction, gridData: data, ticketData: nil, numberIndex: index + 1)
                    }
                }
            }
        }
        return true
    }
}
