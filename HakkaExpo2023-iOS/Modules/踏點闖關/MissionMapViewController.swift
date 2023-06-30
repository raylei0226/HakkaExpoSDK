//
//  MissionMapViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/30.
//

import UIKit
import GoogleMaps

class MissionMapViewController: BasicViewController {
    
    var isFinding: Bool = false
    
    var gridInfoData: GridInfoData?
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var missionTipsLayerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BLEManager.instance.delegate = self
        
        guard let data = gridInfoData else {
            HudManager.shared.showError(withMessage: "發生錯誤，請重新嘗試")
            return
        }

        setupUI(data: data)
        addMarker(data: data)
        missionTipsLayerView.isHidden = isFinding ? false : true
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        BLEManager.instance.stopScan()
    }
    
    private func setupUI(data: GridInfoData) {
   
        navigationItem.title = "關卡地圖"
        missionTipsLayerView.layer.cornerRadius = 12
        missionTipsLayerView.dropShadow()
        
        let lat = (gridInfoData?.nineGrid?.first?.beacon?.lat)!
        let lng = (gridInfoData?.nineGrid?.first?.beacon?.lng)!
        let camera = GMSCameraPosition(latitude: Double(lat)!, longitude: Double(lng)!, zoom: 17)
        mapView.camera = camera
        mapView.mapStyle = try! GMSMapStyle(jsonString: Configs.kMapStyle)
    }
    
    private func addMarker(data: GridInfoData) {
        
        guard let data = data.nineGrid else { return }
        for (index,coordinate) in data.enumerated() {
            let marker = GMSMarker()
            let lat = Double((coordinate.beacon?.lat)!)
            let lng = Double((coordinate.beacon?.lng)!)
            let position = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
            marker.position = position
            let bundle = Bundle(for: MissionMapViewController.self)
            marker.icon = UIImage(named: "checkPoint\(index + 1)", bundle: bundle)
            marker.map = mapView
        }
    }
}

extension MissionMapViewController: BLEManagerDelegate {
    
    func didDiscoverServiceData(_ hwid: String) {
        print("發現Beacon\(hwid)")
    }
}
