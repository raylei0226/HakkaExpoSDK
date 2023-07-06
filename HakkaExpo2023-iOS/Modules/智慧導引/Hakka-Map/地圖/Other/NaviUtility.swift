//
//  NaviUtility.swift
//  NLPI
//
//  Created by Jelico on 2019/12/2.
//  Copyright © 2019  Jolly. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation

enum SlideDirection {case up, down}
enum RouteApiType {case coordinateToPoint, pointToPoint}
enum RouteOrderMode {case normal, reversed}
enum CameraState {case fixUser, fixNorth, flexible}
enum RowViewType {case poi, exhibit}
enum DivisionMenuType {case divisionMain, divisionSub, meetingRoomMain, meetingRoomSub}
enum FromPage {case entry, naviMain}

enum UserDefaultKey: String {
    case historicalKeyword = "historicalKeyword"
    case hadShowedFunction = "hadShowedFunction"
    case userMarkerPosition = "userMarkerPosition"
    case pressLoc_Arrow = "pressLoc_Arrow"
    case pressLoc_User = "pressLoc_User"
}

enum NavigationType: String {
    case emergency = "emergency"
    case findBook = "findBook"
    case findCar = "findCar"
    case mission = "mission"
    case findPushPoi = "findPushPoi"
    case theme = "theme"
}

enum NearbyType: String {
    case Information = "Information"
    case Restroom = "Restroom%20or%20the%20Disabled"
    case AED = "AED"
    case Hydrant = "Hydrant"
    case Elevator = "Elevator"
    case Exit = "EntranceExit"
}

enum ReachType: String {
    case End = "End"
    case NextFloor = "NextFloor"
}

enum EmergencyType: String {
    case EmergencyExit = "Emergency%20exit"
    case Aed = "AED"
    case FireExtinguisher = "Extinguisher"
    case Information = "Reception%20desk"
    case SelfBorrow = "Self%20borrow"
    case SearchArea = "Search%20area"
}

enum EmergencyLiteral: String {
    case EmergencyExit = "緊急疏散"
    case Aed = "AED"
    case FireExtinguisher = "滅火器"
    case Information = "服務台"
    case SelfBorrow = "自助借書區"
    case SearchArea = "檢索區"
}

enum MarkerMode: String {
    case Default = "Default"
    case WatchFriend = "WatchFriend"
    case PickGatherPoint = "PickGatherPoint"
    case GoGatherPoint = "GoGatherPoint"
}

enum NAVIAsset {
    case logoImgGray
    case btn_back
    case btn_back_white
    case map_btn_search
    case upDownSwitch01
    case upDownSwitch02
    case beginDot01
    case beginDot02
    case endDot01
    case endDot02
    case btn_bar_dot
    case guide_ping
    case blueDot
    case nav_arrow
    case icon_select
    case arrow_left
    case arrow_slightLeft
    case arrow_right
    case arrow_slightRight
    case arrow_straight
    case down_arrow
    case btn_map_switch_close
    
    var img: UIImage {
        switch self {
        case .logoImgGray:
            return UIImage(named: "logoImgGray", in: Configs.Bunlde(), compatibleWith: nil)!
        case .btn_back:
            return UIImage.icon(name: "btn_back", bundle: Bundle(for: NaviMainVC.self)).withRenderingMode(.alwaysOriginal)
        case .btn_back_white:
            return UIImage.icon(name: "btn_back_white", bundle: Bundle(for: NaviMainVC.self)).withRenderingMode(.alwaysOriginal)
        case .map_btn_search:
            return UIImage.icon(name: "map_btn_search", bundle: Bundle(for: NaviMainVC.self)).withRenderingMode(.alwaysOriginal)
        case .upDownSwitch01:
            return UIImage.icon(name: "upDownSwitch01", bundle: Bundle(for: NaviMainVC.self))
        case .upDownSwitch02:
            return UIImage.icon(name: "upDownSwitch02", bundle: Bundle(for: NaviMainVC.self))
        case .beginDot01:
            return UIImage.icon(name: "beginDot01", bundle: Bundle(for: NaviMainVC.self))
        case .beginDot02:
            return UIImage.icon(name: "beginDot02", bundle: Bundle(for: NaviMainVC.self))
        case .endDot01:
            return UIImage.icon(name: "endDot01", bundle: Bundle(for: NaviMainVC.self))
        case .endDot02:
            return UIImage.icon(name: "endDot02", bundle: Bundle(for: NaviMainVC.self))
        case .btn_bar_dot:
            return UIImage.icon(name: "btn_bar_dot", bundle: Bundle(for: NaviMainVC.self))
        case .guide_ping:
            return UIImage.icon(name: "guide_ping", bundle: Bundle(for: NaviMainVC.self))
        case .blueDot:
            return UIImage.icon(name: "blueDot", bundle: Bundle(for: NaviMainVC.self))
        case .nav_arrow:
            return UIImage.icon(name: "nav_arrow", bundle: Bundle(for: NaviMainVC.self))
        case .icon_select:
            return UIImage.icon(name: "icon_select", bundle: Bundle(for: NaviMainVC.self))
        case .arrow_left:
            return UIImage.icon(name: "arrow_left", bundle: Bundle(for: NaviMainVC.self))
        case .arrow_slightLeft:
            return UIImage.icon(name: "arrow_slightLeft", bundle: Bundle(for: NaviMainVC.self))
        case .arrow_right:
            return UIImage.icon(name: "arrow_right", bundle: Bundle(for: NaviMainVC.self))
        case .arrow_slightRight:
            return UIImage.icon(name: "arrow_slightRight", bundle: Bundle(for: NaviMainVC.self))
        case .arrow_straight:
            return UIImage.icon(name: "arrow_straight", bundle: Bundle(for: NaviMainVC.self))
        case .down_arrow:
            return UIImage.icon(name: "down_arrow", bundle: Bundle(for: NaviMainVC.self))
        case .btn_map_switch_close:
            return UIImage.icon(name: "btn_map_switch_close", bundle: Bundle(for: NaviMainVC.self))
        }
    }
}

class NaviUtility {
    static let projectColor = (NaviProject.id == "1") ?  NaviProject.color : #colorLiteral(red: 0, green: 0.4431372549, blue: 0.7137254902, alpha: 1)
    static let group = DispatchGroup()
    static var planProcessing = false
    static var hasDownloadPlanData = false
    static var onPlanDownloaded: (([PlanModel]) -> Void)?
    static var onAcCategoryDownloaded: (([AcCategoryModel]) -> Void)?
    static var onAacCategoryDownloaded: (([AacCategoryModel]) -> Void)?
    static var ManualSimulateMode = false
    static let NeedAnyWhereTest = false


    static var GetFloorAPI: String {
        return NaviProject.usedProjectModel.get_floorAPI
    }
    
    static var GetNaviNearbyAPI: String {
        return NaviProject.usedProjectModel.get_navi_nearby_typeAPI
    }
    
    static var AcCategoryAPI: String {
        return NaviProject.usedProjectModel.ac_categoryAPI
    }
    
    static var GetAacCategoryAPI: String {
        return NaviProject.usedProjectModel.get_aac_categoryAPI
    }
    
    static var GetKeyWordAPI: String {
        return NaviProject.usedProjectModel.get_keywordAPI
    }
    
    static var ThemeGuideAPI: String {
        return NaviProject.usedProjectModel.get_theme_guideAPI
    }
    
    static var GetNaviRouteXyAPI: String {
        return NaviProject.usedProjectModel.get_navi_route_xyAPI
    }
    
    //friend group
    static var SendUserLocationAPI: String {
        return NaviProject.usedProjectModel.send_user_locationAPI
    }

    static var JoinGroupAPI: String {
        return NaviProject.usedProjectModel.join_groupAPI
    }

    static var AddGroupAPI: String {
        return NaviProject.usedProjectModel.add_groupAPI
    }
    
    static var UpdateGroupAPI: String {
        return NaviProject.usedProjectModel.update_groupAPI
    }
    
    static var LeaveGroupAPI: String {
        return NaviProject.usedProjectModel.leave_groupAPI
    }

    static func NotificationPost(name: Notification.Name) {
        NotificationCenter.default.post(name: name, object: nil)
    }

    static func SaveUserValue(key: UserDefaultKey, value: Any?) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func GetUserValue(by key: UserDefaultKey) -> Any? {
        let value = UserDefaults.standard.value(forKey: key.rawValue)
        return value
    }
    
    static func DeleteUserValue(by key: UserDefaultKey) {
        UserDefaults.standard.set(nil, forKey: key.rawValue)
    }

    static func GlobalAlert(title: String?, message: String?, actText: String) {
        DispatchQueue.main.async {
            let alertWindow = self.GetWindow()
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let doneAction = UIAlertAction(title: actText, style: .cancel) { action in
                // 用 doneAction 的 handler 閉包去持有 alertWindow，創造一個臨時的循環持有。
                // 在 alertController 被釋放後，這些閉包也會被釋放，跟著把 alertWindow 給釋放掉。
                _ = alertWindow
            }
            alertController.addAction(doneAction)
            alertWindow.rootViewController?.present(alertController, animated: true, completion: {
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        }
    }

    static func GetWindow() -> UIWindow {
        let window = UIWindow()
        window.backgroundColor = nil
        window.windowLevel = .alert
        window.rootViewController = UIViewController()
        window.isHidden = false
        return window
    }
    
    static func GetPoiModel(by marker: GMSMarker ) -> OGPointModel? {
        for poi in NaviProject.presentedPoiModels {
            if poi.id == marker.userData as? Int {
                return poi
            }
        }
        return nil
    }
    
    static func GetPoiModels(by poiDatas: [OGPointModel]) -> [OGPointModel] {
        var poiModels: [OGPointModel] = []
        
        for p in poiDatas {
            poiModels.append(p)
        }
        return poiModels
    }
    
    static func RetrievePoiModels(by planId: String?, ac_id: Int?, aac_id: Int?, planModels: [PlanModel]) -> [OGPointModel] {
        for planModel in planModels {
            //過濾樓層
            if planModel.plan_id == planId {
                let allPoiModels = self.GetPoiModels(by: planModel.pois)
                
                if let ac_id = ac_id {
                    //回傳推薦類別poi
                    var filteredModels: [OGPointModel] = []
                    allPoiModels.forEach({
                        ($0.ac_id == ac_id) ? filteredModels.append($0) : nil
                    })
                    return filteredModels
                }else {
                    if aac_id == 0 {
                        //回傳全部poi
                        return allPoiModels
                    }else {
                        //回傳指定圖層類別poi
                        var filteredModels: [OGPointModel] = []
                        allPoiModels.forEach({
                            ($0.aac_id == aac_id) ? filteredModels.append($0) : nil
                            
                        })
                        return filteredModels
                    }
                }
            }
        }
        return []
    }

    static func IsProjectPlanId(planId: String) -> Bool {
        for planModel in NaviProject.planModels {
            if planModel.plan_id == planId {
                return true
            }
        }
        return false
    }
    
    static func GetPlanId(by floorNumber: Int) -> String? {
        for planModel in NaviProject.planModels {
            if planModel.number == floorNumber {
                return planModel.plan_id
            }
        }
        return nil
    }
    
    /**取得所有樓層編號*/
    static func GetFloorNumbers() -> [Int] {
        var numbers = [Int]()
        NaviProject.planModels.forEach({
            numbers.append($0.number)
        })
        return numbers
    }

    /**取得所有樓層名稱*/
    static func GetFloorNames() -> [String] {
        var names = [String]()
        NaviProject.planModels.forEach({
            names.append($0.name)
        })
        return names
    }
    
    /**依樓層名稱取得樓層編號*/
    static func GetFloorNumber(at name: String) -> Int {
        if let floor = NaviProject.planModels.filter({$0.name == name}).first {
            return floor.number
        }
        return 1
    }
    
    static func GetFloorNumber(by planId: String?) -> String? {
        if let floor = NaviProject.planModels.filter({$0.plan_id == planId}).first {
            return floor.order
        }
        return nil
    }
    
    static func GetFloorName(by planId: String) -> String {
        if let floor = NaviProject.planModels.filter({$0.plan_id == planId}).first {
            return floor.name
        }
        return ""
    }
    
    static func GetFloorName(by number: Int) -> String {
        switch number {
        case -1:
            return "B1"
        case -2:
            return "B2"
        case -3:
            return "B3"
        case -4:
            return "B4"
        default:
            return "\(number)F"
        }
    }

    static func CreateCustomBtn(_ title: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.1
        let titleColor = NaviUtility.projectColor
        btn.setTitleColor(titleColor, for: .normal)
        btn.backgroundColor = .white
        return btn
    }
    
    enum HttpMethod: String {
        case get = "get"
        case post = "post"
    }

    static func ParameterString(parameters: [String: String], method: HttpMethod) -> String {
        var parameterString = ""

        switch method {
        case .get:
            for parameter in parameters {
                let key = parameter.key
                let value = parameter.value
                parameterString += "\(key)=\(value)&"
            }
            return parameterString
        case .post:
            for parameter in parameters {
                let key = parameter.key
                let value = parameter.value
                parameterString += "&\(key)=\(value)"
            }
        }
        return parameterString
    }

    static func GetNearbyParameters(by userFloor: String, userCoordinate: CLLocationCoordinate2D, type: String) -> [String: String] {
        let lat = String(userCoordinate.latitude)
        let lng = String(userCoordinate.longitude)
        
        let dic = ["lat": lat,
                   "lng": lng,
                   "f": userFloor,
                   "type": type]
        return dic
    }

    static func GetRouteXyParameters(by userFloor: String, beginCoordinate: CLLocationCoordinate2D, priority: String, poiModel: OGPointModel) -> [String: String] {
        let p = String(poiModel.id)
        let lat = String(beginCoordinate.latitude)
        let lng = String(beginCoordinate.longitude)
        
        let dic = ["p": p,
                   "lat": lat,
                   "lng": lng,
                   "f": userFloor,
                   "priority": priority]
        return dic
    }
    
    static func GetRouteParameters(beginPoiId: String, priority: String, poiModel: OGPointModel) -> [String: String] {
        let b_id = String(poiModel.id)
        
        let dic = ["a": beginPoiId,
                   "b": b_id,
                   "priority": priority]
        return dic
    }
    
    static func GetCoordinate(from poiModel: OGPointModel) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: poiModel.lat, longitude: poiModel.lng)
    }
    
    static func GetCoordinate(latStr: String, lngStr: String) -> CLLocationCoordinate2D {
        let userLat = CLLocationDegrees(latStr)!
        let userLng = CLLocationDegrees(lngStr)!
        let coordinate = CLLocationCoordinate2D(latitude: userLat, longitude: userLng)
        return coordinate
    }

    typealias completedRouteData = (_ beginFloorNumber: String,
                                    _ beginLat: Double,
                                    _ beginLng: Double,
                                    _ floorNumberDic: NSMutableDictionary,
                                    _ nodeCountArray: [Int],
                                    _ beginCoordinateArray: [CLLocation],
                                    _ endCoordinateArray: [CLLocation],
                                    _ guideFloorNumArray: [String],
                                    _ pickedFloorNumber: String,
                                    _ endLat: Double,
                                    _ endLng: Double,
                                    _ endFloorNum: String,
                                    _ endLocation: CLLocation) -> ()

    static func HandleOriginalRouteData(routeArray: [[String: Any]], completion: @escaping completedRouteData) {
        var beginFloorNumber = ""
        var beginLat: Double!
        var beginLng: Double!
        let floorRouteDic: NSMutableDictionary! = [:]
        var nodeCountArray: [Int] = []
        var beginCoordinateArray: [CLLocation] = []
        var endCoordinateArray: [CLLocation] = []
        var guideFloorNumArray: [String] = []
        var pickedFloorNumber = ""
        var endLat: Double!
        var endLng: Double!
        var endFloorNum: String!
        var endLocation: CLLocation!

        //開始按照樓層number分組，結構(由外至內)：[Dic[Array[Dic]]]（參考工作記錄）
        var number = ""
        var array: [[String: Double]] = []

        //同樓層第二個樓層碼
        var underlineNum = ""
        
        //<終點機制
        //暫存前一樓的最後一個節點座標，用於前一個樓層路線終點（下方if number != floor_number）
        var previousLat = CLLocationDegrees()
        var previousLng = CLLocationDegrees()
        
        for i in 0..<routeArray.count {
            let pointDic = routeArray[i]
            
            guard let floor_number = pointDic["floor_number"] as? String else {
                return
            }
            
            //儲存該樓的路線終點座標、路線節點數
            if number != floor_number {
                if number != "" {
                    if underlineNum != "" {
                        //若有underlineNum，將其作為樓層碼
                        floorRouteDic.setValue(array, forKey: underlineNum)
                        underlineNum = ""
                    }else {
                        floorRouteDic.setValue(array, forKey: number)
                    }
                    //每層樓路線節點數
                    nodeCountArray.append(array.count)
                    
                    //每層樓終點座標
                    let pathEndCoor = CLLocation(latitude: previousLat, longitude: previousLng)
                    endCoordinateArray.append(pathEndCoor)
                    
                    //每層樓起點座標
                    let lat = CLLocationDegrees(pointDic["lat"] as! String)!
                    let lng = CLLocationDegrees(pointDic["lon"] as! String)!
                    let pathBeginCoor = CLLocation(latitude: lat, longitude: lng)
                    beginCoordinateArray.append(pathBeginCoor)
                }
                
                //樓層名稱
                guideFloorNumArray.append(floor_number)
                //>
                
                //<處理同一樓層兩條路線，同樓層儲存兩條路線：3、3_1
                let floorKeys = (floorRouteDic.allKeys as! [String])
                for i in 0..<floorKeys.count {
                    if floor_number == floorKeys[i] {
                        underlineNum = floor_number + "_1"
                    }
                }
                //>
                
                number = floor_number
                array = []
            }
            let lat = Double(pointDic["lat"] as! String)!
            let lng = Double(pointDic["lon"] as! String)!
            
            previousLat = lat
            previousLng = lng
            
            var dic: [String: Double] = [:]
            
            dic["lat"] = lat
            dic["lon"] = lng
            
            array.append(dic)
            
            //路線「起點」位置
            if i == 0 {
                beginLat = lat
                beginLng = lng
                beginFloorNumber = floor_number
                pickedFloorNumber = floor_number

                //每層樓起點座標
                let pathBeginCoor = CLLocation(latitude: previousLat, longitude: previousLng)
                beginCoordinateArray.append(pathBeginCoor)
            }
            
            // 掃到最後一個了，做最後的儲存
            if i == (routeArray.count - 1) {
                //若有underlineNum，將其作為樓層碼
                if underlineNum != "" {
                    floorRouteDic.setValue(array, forKey: underlineNum)
                }else {
                    floorRouteDic.setValue(array, forKey: number)
                }
                
                //<終點機制
                //每層樓路線節點數
                nodeCountArray.append(array.count)
                //路線終點座標
                let pathEndCoor = CLLocation(latitude: previousLat, longitude: previousLng)
                endCoordinateArray.append(pathEndCoor)
                //>
                
                //路線「目的地」位置
                endLat = lat
                endLng = lng
                endFloorNum = floor_number
                endLocation = CLLocation(latitude: lat, longitude: lng)
            }
        }
        completion(beginFloorNumber,
                   beginLat,
                   beginLng,
                   floorRouteDic,
                   nodeCountArray,
                   beginCoordinateArray,
                   endCoordinateArray,
                   guideFloorNumArray,
                   pickedFloorNumber,
                   endLat,endLng,
                   endFloorNum,
                   endLocation)
    }
    
    static func getPath(floorRouteArray: [[String: Double]]) -> GMSMutablePath {
        let path = GMSMutablePath()
        
        for i in 0..<floorRouteArray.count {
            let coordinateDic = floorRouteArray[i]
            let lat = CLLocationDegrees(coordinateDic["lat"]!)
            let lon = CLLocationDegrees(coordinateDic["lon"]!)
            let coordinate = CLLocationCoordinate2DMake(lat, lon)
            path.add(coordinate)
        }
        return path
    }
    
    static func getPolyLine(path: GMSMutablePath, color: UIColor, width: CGFloat) -> GMSPolyline {
        let polyline = GMSPolyline(path: path)
        let lineColor = GMSStrokeStyle.gradient(from: color, to: color)
        polyline.spans = [GMSStyleSpan(style: lineColor)]
        polyline.strokeWidth = width
        polyline.geodesic = true
        polyline.zIndex = 101
        
        return polyline
    }
    
    static func getFocusedPath(path1: GMSMutablePath, path2: GMSMutablePath, userCoordinate: CLLocationCoordinate2D) -> GMSMutablePath {
        //<判斷離哪條近-判斷用戶與兩條線上每個點的距離
        var path1CoorDistance: [CLLocationDistance] = []
        var path2CoorDistance: [CLLocationDistance] = []

        for i in 0..<path1.count() {
            let lat = path1.coordinate(at: i).latitude
            let lng = path1.coordinate(at: i).longitude
            let coordinate = CLLocation(latitude: lat, longitude: lng)
            let distance = coordinate.distance(from: userCoordinate.location)
            path1CoorDistance.append(distance)
        }
        path1CoorDistance = path1CoorDistance.sorted { $0 < $1 }
        
        for i in 0..<path2.count() {
            let lat = path2.coordinate(at: i).latitude
            let lng = path2.coordinate(at: i).longitude
            let coordinate = CLLocation(latitude: lat, longitude: lng)
            let distance = coordinate.distance(from: userCoordinate.location)
            path2CoorDistance.append(distance)
        }
        path2CoorDistance = path2CoorDistance.sorted { $0 < $1 }
        
        //指定要定箭頭在哪條線
        if path1CoorDistance.first! < path2CoorDistance.first! {
            return path1
        }else {
            return path2
        }
    }

    static func fitPath(path: GMSMutablePath, mapView: GMSMapView) {
        var bounds = GMSCoordinateBounds()
        for index in 0..<path.count() {
            bounds = bounds.includingCoordinate(path.coordinate(at: index))
        }
        
        DispatchQueue.main.async(execute: {
            // 使畫面剛好包住路線
            mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30))
            mapView.padding.top = 270
            mapView.padding.bottom = 100
        })
    }

    typealias completedArrowData = (_ position: CLLocation?,
                                    _ distance: Double?,
                                    _ segmentBeginIndex: UInt?) -> ()

    // 算出使用者到路線最短的垂直距離，接著取得C點(使用者)垂直投影到AB線段上的座標，標示箭頭，計算螢幕旋轉角度
    static func CaculateArrowData(userCoordinate: CLLocationCoordinate2D?, focusedPath: GMSPath, completion: @escaping completedArrowData) {
        //計算使用者與每線段之垂直距離，比較出最近，將該線段頭尾(A、B)座標定出來，然後在該線段標出距離使用者最近的座標（即垂直距離）
        
        //需要用戶坐標，且路徑資料須兩個點(座標)以上
        guard
            let coordinate = userCoordinate,
            focusedPath.count() >= 2
        else {
            completion(nil, nil, nil)
            return
        }
        
        let cx = coordinate.longitude
        let cy = coordinate.latitude
        
        var Ax: CLLocationDegrees!
        var Ay: CLLocationDegrees!
        var Bx: CLLocationDegrees!
        var By: CLLocationDegrees!
        
        var R: Double!

        var nearestDistance: Double!
        var segmentBeginIndex: UInt!
        
        // 計算次數
        var pathCount: UInt = 1
        
        // 比較所有線段
        for i in 0..<focusedPath.count() - 1 {
            let ax = focusedPath.coordinate(at: i).longitude
            let ay = focusedPath.coordinate(at: i).latitude
            
            let bx = focusedPath.coordinate(at: i + 1).longitude
            let by = focusedPath.coordinate(at: i + 1).latitude
                        
            let r_numerator_1 = (cx - ax) * (bx - ax)
            let r_numerator_2 = (cy - ay) * (by - ay)
            let r_numerator = r_numerator_1 + r_numerator_2
            
            let r_denomenator_1 = (bx - ax) * (bx - ax)
            let r_denomenator_2 = (by - ay) * (by - ay)
            let r_denomenator = r_denomenator_1 + r_denomenator_2
            
            let r = r_numerator / r_denomenator
            
            // 使用者投影位置處於線段上
            if (r >= 0) && (r <= 1) {
                let s1 = (ay - cy) * (bx - ax)
                let s2 = (ax - cx) * (by - ay)
                let s3 = s1 - s2
                let s4 = s3 / r_denomenator
                
                let distanceLine = fabs(s4) * sqrt(r_denomenator)
                
                if nearestDistance == nil {
                    nearestDistance = distanceLine
                }
                
                // 篩選出垂直距離使用者最短的垂直線，將該垂直線對應到的路線選出來、再將該垂直線對應到的點座標定出來(A、B)
                if distanceLine <= nearestDistance! {
                    nearestDistance = distanceLine
                    
                    //最接近使用者的線段(segment)節點序號
                    segmentBeginIndex = i
                    
                    R = r
                    
                    // 距離使用者最近的線段的頭尾座標
                    // y是latitude , x是longitude
                    Ax = ax
                    Ay = ay
                    Bx = bx
                    By = by
                }
            }
            
            // 比較完線段，準備回傳 箭頭座標、用戶與箭頭距離、節點序號
            if pathCount == focusedPath.count() - 1 {
                // 若無最近線段，終止
                guard (nearestDistance != nil) else {
                    completion(nil, nil, nil)
                    return
                }
                                
                //計算箭頭座標
                DispatchQueue.main.async(execute: {
                    var xx: CLLocationDegrees!
                    var yy: CLLocationDegrees!
                    
                    //箭頭座標-該線段距離使用者最近的位置 (xx,yy) is the point on the lineSegment closest to (cx,cy)
                    xx = Ax + R*(Bx-Ax)
                    yy = Ay + R*(By-Ay)
                    
                    let arrowPosition = CLLocation(latitude: yy, longitude: xx)
                    
                    completion(arrowPosition, nearestDistance, segmentBeginIndex)
                })
            }
            pathCount = pathCount + 1
        }
    }
    
    static func GetSimulateCoordinates(focusedPath: GMSMutablePath) -> [CLLocationCoordinate2D] {
        let count = focusedPath.count()
        var pointArr: [CLLocationCoordinate2D] = []
        
        for i in 0..<count {
            let coordinate = focusedPath.coordinate(at: i)
            pointArr.append(coordinate)
        }
        
        var previous: CLLocationCoordinate2D!
        var coordinates = [CLLocationCoordinate2D]()

        for point in pointArr {
            if previous == nil {
                previous = point
                continue
            }

            coordinates += CreateCoordinates(from: previous, to: point)
            previous = point
        }
        return coordinates
    }
    
    static func CreateCoordinates(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        let detaX = end.longitude - start.longitude
        let detaY = end.latitude - start.latitude
        var theta = atan(detaY / detaX)
        
        // Adjust Theta while Swift Only Result in -90º ~ 90º
        if (theta < 0 && detaX < 0 && detaY > 0) || (theta > 0 && detaX < 0 && detaY < 0) {
            theta += Double.pi
        }
        let maxDistance = start.distance(to: end)
        var distance = 0.0
        
        //每1公尺一個座標
        while maxDistance - distance > Paras.walkGap {
            let lng = start.longitude + distance * cos(theta) / 100000
            let lat = start.latitude + distance * sin(theta) / 100000
            coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lng))
            distance += Paras.walkGap
        }
        return coordinates
    }
    
    static func AddChildVc(controller: UIViewController, childVc: UIViewController, container: UIView) {
        childVc.view.frame = container.frame
        childVc.view.center = CGPoint(x: container.frame.width / 2, y: container.frame.height / 2)
        childVc.view.clipsToBounds = true
        childVc.didMove(toParent: controller)
        controller.addChild(childVc)
        container.addSubview(childVc.view)
    }

    static func DispatchGroupCount(group: DispatchGroup) -> Int? {
        guard let count = group.debugDescription.components(separatedBy: ",").filter({$0.contains("count")}).first?.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap({Int($0)}).first else {
            return nil
        }
        return count
    }
    
    //有定位版本
    static func checkIsInProjectRegion(completion: @escaping ((Bool, CLLocationCoordinate2D) -> Void)) {
        guard let userCoordinate = LocationBase.shared.coordinate else {
            NaviUtility.ShowAlert("無位置資訊")
            return
        }

        let isInProjectRegion = NaviUtility.IsInProjectRegion(coordinate: userCoordinate)
        let coordinate = isInProjectRegion ? userCoordinate : NaviProject.usedProjectModel.defaultUserCoordinate!
        completion(isInProjectRegion, coordinate)
    }
    
    static func IsInProjectRegion(coordinate: CLLocationCoordinate2D) -> Bool {
        guard LocationBase.shared.enteredProjectPlanId != nil else {
            return false
        }
        return true
    }
    
    static func GetReversedRoute(route: [[String: Any]]) -> [[String: Any]] {
        let normalRoute = route
        let reversed = Array(normalRoute.reversed())
        return reversed
    }
    
    static func GetProjectModel(projectId: String) -> ProjectModel? {
        guard let projectModel = ProjectModelList().ModelList.filter({$0.id == projectId}).first else {
            return nil
        }
        return projectModel
    }
    
    static func CreatePoiModel(location: CLLocation, id: Int, ac_id: Int, floorNumber: Int, name: String) -> OGPointModel {
        let poiModel = OGPointModel(data: ["lat": location.coordinate.latitude,
                                           "lng": location.coordinate.longitude,
                                           "id": id,
                                           "ac_id": ac_id,
                                           "number": floorNumber,
                                           "name": name])
        return poiModel
    }
    
    static func GetPoiModelsBy(planId: String?, begin: OGPointModel?, end: OGPointModel?) -> [OGPointModel] {
        var poiModels: [OGPointModel] = []
        
        if let floorNumber = NaviUtility.GetFloorNumber(by: planId) {
            if begin != nil, begin!.number == Int(floorNumber) {
                poiModels.append(begin!)
            }
            
            if end != nil, end!.number == Int(floorNumber) {
                poiModels.append(end!)
            }
            return poiModels
        }
        return []
    }
    
    static func SaveHistoricalKeyword(_ keyword: String) {
        var historicalKeywords = self.GetUserValue(by: .historicalKeyword) as? [String] ?? []
        
        //不重複才紀錄
        if !(historicalKeywords.contains(keyword)) {
            historicalKeywords.insert(keyword, at: 0)
        }
        
        //只保留10筆
        if historicalKeywords.count > 10 {
            for _ in 10..<historicalKeywords.count {
                historicalKeywords.removeLast()
            }
        }
        
        self.SaveUserValue(key: .historicalKeyword, value: historicalKeywords)
        NaviUtility.NotificationPost(name: .reloadHistoricalKeyword)
    }
    
    func GenerateDirectionMarkersBy(_ coordinates: [CLLocationCoordinate2D]) -> [GMSMarker] {
        var markers:[GMSMarker] = []
        
        for i in 0..<coordinates.count {
            guard (i + 1) < coordinates.count else {
                return markers
            }
            let marker = GMSMarker()
            marker.position = coordinates[i]
            
            let point1 = coordinates[i]
            let point2 = coordinates[i + 1]
            let rotation = NaviUtility.GetBearingBetweenTwoPoints(point1: point1, point2: point2)
            
            marker.rotation = rotation
            marker.icon = UIImage().poiTypeToImage(ac_id: 20000,
                                                   bundle: Bundle(for: MapVC.self))
            markers.append(marker)
        }
        
        return markers
    }
    
    //計算螢幕旋轉角度，用於導航
    static func DegreesToRadians(degrees: Double) -> Double {
        return degrees * Double.pi / 180.0
    }
    
    static func RadiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / Double.pi
    }
    
    static func GetBearingBetweenTwoPoints(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {
        let lat1 = self.DegreesToRadians(degrees: point1.latitude)
        let lon1 = self.DegreesToRadians(degrees: point1.longitude)
        
        let lat2 = self.DegreesToRadians(degrees: point2.latitude)
        let lon2 = self.DegreesToRadians(degrees: point2.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
                
        return self.RadiansToDegrees(radians: radiansBearing)
    }
    
    static func RotateDirectionMarkers(mapBearing: CLLocationDirection?, markers: [GMSMarker]) {
        guard markers.count > 0 else {
            return
        }
        
        guard let mapBearing = mapBearing else {
            return
        }
        
        for i in 0..<markers.count - 1 {
            let markerBearing = NaviUtility.GetBearingBetweenTwoPoints(point1: markers[i].position, point2: markers[i + 1].position)
            markers[i].rotation = -mapBearing + markerBearing
        }
    }
    
    static func Open(_ naviMainVC: NaviMainVC, from controller: UIViewController, keyword: String? = nil, _ point: OGPointModel? = nil, nearbyType: NearbyType? = nil) {
        naviMainVC.keyword = keyword
        naviMainVC.poi = point
        naviMainVC.nearbyType = nearbyType
        controller.show(naviMainVC, sender: controller)
    }
    
    static func ShowAlert(withTitle title: String?, message: String?, confirmHandler:  @escaping ((UIAlertAction) -> Void) = {_ in}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler:confirmHandler))
        
        if var topVC = UIApplication.shared.keyWindow?.rootViewController {
            while let nextVC = topVC.presentedViewController {
                topVC = nextVC
            }
            DispatchQueue.main.async {
                topVC.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    static func GetPoiBy(_ id: Int) -> OGPointModel? {
        for plan in NaviProject.planModels {
            for poi in plan.pois {
                if (poi.id == id) {
                    return poi
                }
            }
        }
        return nil
    }
    
    static var TestPlanId: String {
        return "\(NaviProject.usedProjectModel.testPlanId)"
    }

    static func ShowGatherMarker(map:GMSMapView, gatherName: String, latitude: Double, longitude: Double) {
        let marker = GMSMarker()
        marker.icon = UIImage(named: "icon_terminal_point")
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.title = gatherName
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.zIndex = 100
        marker.map = map
    }
    
    static func CustomNavigationBar(_ nvController: UINavigationController?, _ barTintColor: UIColor, _ titleTextAttributes: [NSAttributedString.Key: Any]) {
        nvController?.navigationBar.barTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        nvController?.navigationBar.titleTextAttributes = [.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
    }
    
    static func CustomLeftBarButtonItem(_ controller: UIViewController, action: Selector) {
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(image: NAVIAsset.btn_back.img, style: .plain, target: controller, action: action)
    }
    
    static func CustomBackBarButtonItem(_ controller: UIViewController, action: Selector, image: UIImage) {
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: controller, action: action)
    }
    
    static func CustomRightBarButtonItem(_ controller: UIViewController, action: Selector, image: UIImage) {
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: controller, action: action)
    }
    
    static func GetDistance(_ coordinateA: CLLocationCoordinate2D, _ coordinateB: CLLocationCoordinate2D) -> String {
        let distance = coordinateA.distance(to: coordinateB)
        let suffixText = (distance > 999) ? "公里":"公尺"
        let literalDistance = (distance > 999) ? String(format: "%.1f", distance/1000) : String(format: "%.0f", distance)
        let distanceStr = literalDistance + suffixText
        return distanceStr
    }
    
    static func DownloadImage(url: URL) -> UIImage? {
        do {
            let data = try Data(contentsOf: url)
            let image = UIImage(data: data)
            return image
        }catch let error {
           PrintLog(logs: [error.localizedDescription], title: "Get Image Error-")
        }
        return nil
    }
    
    
    static func GetPlanData() {
        self.group.enter()
        self.group.enter()
        self.planProcessing = true

        self.group.notify(queue: .main) {
            self.planProcessing = false
            self.hasDownloadPlanData = true
        }
        
        HTTPSClient().getData(NaviUtility.GetFloorAPI, completion: {Datas in
            self.didHandlePlanData(datas: Datas)
            self.group.leave()
        })
        
        HTTPSClient().getData(NaviUtility.GetAacCategoryAPI, completion: {Datas in
            self.didHandleAacCategoryData(datas: Datas)
            self.group.leave()
        })
    }
    
    static func didHandlePlanData(datas: Data?) {
        guard
            let data = datas,
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else {
            return
        }
        
        let datas = jsonData["data"] as? [[String: Any]] ?? []
        let planModels = datas.map({PlanModel(data: $0)})
        
        if let onPlanDownloaded = self.onPlanDownloaded {
            onPlanDownloaded(planModels)
        }
                    
        //給智能搜尋-呈現樓層POI列表
        OGGlobalData().setFloorPointData(datas, completionHandler: nil)
    }
    
    static func didHandleAacCategoryData(datas: Data?) {
        guard
            let data = datas,
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else {
            return
        }

        let datas = jsonData["data"] as? [[String: Any]] ?? []
        let aacCategoryModels = datas.map({AacCategoryModel(data: $0)})
                
        if let onAacCategoryDownloaded = self.onAacCategoryDownloaded {
            onAacCategoryDownloaded(aacCategoryModels)
        }
    }
    
    static func RetrieveNearbyPoi(_ routeArray: [[String: Any]]) -> OGPointModel {
        let nearbyName = GlobalState.nearbyName ?? ""
        let floorNumber = routeArray.last!["floor_number"] as? String ?? "1"
        let floorInt = Int(floorNumber)!
        let nearbyPoi = OGPointModel(data: ["name" : nearbyName, "number":floorInt])

        if let lat = (routeArray.last!["lat"] as? String), let latDouble = Double(lat), let lon = (routeArray.last!["lon"] as? String), let lonDouble = Double(lon) {
            let coordinate = CLLocationCoordinate2D(latitude: latDouble, longitude: lonDouble)
            nearbyPoi.coordinate = coordinate
        }
        
        return nearbyPoi
    }
    
    static func CheckUserLocationReady(complement: @escaping (() -> Void) = {}) {
        LoadingAnimation.shared.start(title: Paras.positioningText)

        if (LocationBase.shared.coordinate == nil) {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                self.CheckUserLocationReady(complement: complement)
            })
        }else {
            LoadingAnimation.shared.stop()
            complement()
        }
    }

    static func ShowAlert(_ title: String? = nil, message: String? = nil, cancelHandler: @escaping (() -> Void) = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { _ in
            DispatchQueue.main.async {
                cancelHandler()
            }
        }))
        self.ShowAlertByTopVC(alert)
    }

    static func ShowConfirmAlert(_ title: String? = nil, confirm: String, message: String? = nil, confirmHandler: @escaping (() -> Void) = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: confirm, style: .destructive, handler: { _ in
            DispatchQueue.main.async {
                confirmHandler()
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.ShowAlertByTopVC(alert)
    }

    static func ShowAlertByTopVC(_ alert: UIAlertController) {
        if var topVC = UIApplication.shared.keyWindow?.rootViewController {
            while let nextVC = topVC.presentedViewController {
                topVC = nextVC
            }
            DispatchQueue.main.async {
                topVC.present(alert, animated: true, completion: nil)
            }
        }
    }
}

enum PressedLocType {case user, arrow}

func RecordPressedLoc(loc: CLLocation, type: PressedLocType) {
    let dateFormstter = DateFormatter()
    dateFormstter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
    let timeMark = dateFormstter.string(from: Date())
    let lat = Float(loc.coordinate.latitude)
    let lng = Float(loc.coordinate.longitude)
    let newPosition = "\(timeMark) \(lat) \(lng)"
    
    switch type {
    case .user:
        var positions = NaviUtility.GetUserValue(by: .pressLoc_User) as? String ?? ""
        
        if CountOver(5000, in: positions) {
            NaviUtility.DeleteUserValue(by: .pressLoc_User)
            positions = ""
        }
        positions += "\(newPosition),"
        NaviUtility.SaveUserValue(key: .pressLoc_User, value: positions)
        
    case .arrow:
        var positions = NaviUtility.GetUserValue(by: .pressLoc_Arrow) as? String ?? ""
        
        if CountOver(5000, in: positions) {
            NaviUtility.DeleteUserValue(by: .pressLoc_Arrow)
            positions = ""
        }
        positions += "\(newPosition),"
        NaviUtility.SaveUserValue(key: .pressLoc_Arrow, value: positions)
    }
}

func CountOver(_ limit: Int, in givenStr: String) -> Bool {
    let split = givenStr.split(separator: ",")
    return (split.count > limit) ? true : false
}

func PrintLog(logs: [String], title: String) {
    print("\n---------------------------\(title)-----------------------------------")
    for log in logs {
        print(log)
    }
    print("-----------------------------END-------------------------------------\n")
}
