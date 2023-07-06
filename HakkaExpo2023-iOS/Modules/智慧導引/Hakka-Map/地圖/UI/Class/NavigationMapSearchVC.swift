//
//  NavigationSearchVC.swift
//  NAVISDK
//
//  Created by 李東儒 on 2020/6/16.
//  Copyright © 2020 omniguider. All rights reserved.
//

import UIKit
import CoreLocation

protocol NavigationSearchDelegate {
    func navSearchDidSelect(_ point: OGPointModel?, _ coordinate: CLLocationCoordinate2D?, type: NavigationPresenter.NavigationType)
    func navSearchDidStartChooseMode()
}

class NavigationMapSearchVC: UIViewController {
    var delegate:NavigationSearchDelegate?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var searchResults = [OGPointModel]()

    private var isShowUserLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setSystemSections(_ isShowUserLocation: Bool) {
        self.isShowUserLocation = isShowUserLocation
        self.clearViews()
    }
    
    private func setupViews() {
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
    }
    
    func clearViews() {
        self.textField.text = nil
        self.searchResults = [OGPointModel]()
        self.tableView.reloadData()
    }
    
    private func updateUserLocation() {
        NaviUtility.checkIsInProjectRegion( completion: { isInProjectRegion,coordinate in
            self.delegate?.navSearchDidSelect(nil, coordinate, type: .userLocation)
        })
    }
}

//MARK: - TableView DataSource/Delegate
extension NavigationMapSearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.isShowUserLocation ? 2 : 1
        case 1:
            return self.searchResults.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NavigationSearchCell", for: indexPath) as! NavigationSearchCell
        
        if indexPath.section == 1 {
            cell.setup(with: self.searchResults[indexPath.row])
        }else {
            if isShowUserLocation && indexPath.row == 0 {
                cell.setup(with: NAVIAsset.btn_bar_dot.img, title: "當前位置")
            }else {
                cell.setup(with: NAVIAsset.guide_ping.img, title: "在地圖上選擇位置")
            }
            cell.backgroundColor = UIColor(hex: "#3f3f3f")
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if isShowUserLocation && indexPath.row == 0 {
                self.updateUserLocation()
            }else {
                self.delegate?.navSearchDidStartChooseMode()
            }
        }else {
            self.delegate?.navSearchDidSelect(self.searchResults[indexPath.row], nil, type: .poiLocation)
        }
        self.clearViews()
    }
}

//MARK: - TextField Delegate
extension NavigationMapSearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let keyword = self.textField.text else {
            return false
        }
        
        NaviUtility.checkIsInProjectRegion(completion: {isInProjectRegion,coordinate in
            let lat = coordinate.latitude
            let lng = coordinate.longitude
            let parameter = "&keyword=\(keyword)&lat=\(lat)&lng=\(lng)"
            self.performSearch(parameterString: parameter)
        })

        return true
    }
    
    func performSearch(parameterString: String) {
        //搜尋後台關鍵字
        let searchApi = NaviUtility.GetFloorAPI + parameterString
        HTTPSClient().getEncodedData(searchApi, token: nil, completion: {Datas in
            self.handleSearchResultData(datas: Datas)
        })
        self.textField.endEditing(true)
    }
    
    func handleSearchResultData(datas: Data?) {
        guard
            let data = datas,
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else {
            return
        }
        
        let result = jsonData["result"] as? String ?? ""

        guard result == "true" else {
            let error_message = jsonData["error_message"] as? String ?? ""
            NaviUtility.ShowAlert(nil, message: error_message, cancelHandler: {})
            return
        }
        var planModels: [PlanModel] = []
        let datas = jsonData["data"] as? [[String: Any]] ?? []
        datas.forEach({
            planModels.append(PlanModel(data: $0))
        })
        
        self.searchResults.removeAll()
        
        for planModel in planModels {
            let poiModels = NaviUtility.RetrievePoiModels(by: planModel.plan_id, ac_id: nil, aac_id: 0, planModels: planModels)
            self.searchResults += poiModels
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
