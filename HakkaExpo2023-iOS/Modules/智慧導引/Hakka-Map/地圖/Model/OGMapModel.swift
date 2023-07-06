//
//  OGMapModel.swift
//  OmniGuiderFramework
//
//  Created by 李東儒 on 2021/1/28.
//

import Foundation
import CoreLocation

struct OGFloorModel {
    let id: Int
    let number: Int
    let name: String
    let desc: String
    let order: String
    let coordinate: CLLocationCoordinate2D
    let bl_coordinate: CLLocationCoordinate2D
    let tr_coordinate: CLLocationCoordinate2D
    let plan_id: String
    let is_map: Bool
    
    init(_ dic: [String: Any]) {
        id = dic["id"] as? Int ?? 0
        number = dic["number"] as? Int ?? 0
        name = dic["name"] as? String ?? ""
        desc = dic["desc"] as? String ?? ""
        order = dic["order"] as? String ?? ""
        let lat = dic["lat"] as? Double ?? 0
        let lng = dic["lng"] as? Double ?? 0
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let bl_lat = dic["bl_lat"] as? Double ?? 0
        let bl_lng = dic["bl_lng"] as? Double ?? 0
        bl_coordinate = CLLocationCoordinate2D(latitude: bl_lat, longitude: bl_lng)
        let tr_lat = dic["tr_lat"] as? Double ?? 0
        let tr_lng = dic["tr_lng"] as? Double ?? 0
        tr_coordinate = CLLocationCoordinate2D(latitude: tr_lat, longitude: tr_lng)
        plan_id = dic["plan_id"] as? String ?? ""
        is_map = (dic["is_map"] as? Int ?? 0) == 1
    }
}

class OGPointModel: JSONEnable {
    var id: Int!
    var aac_id: Int!
    var ac_id: Int!
    var puid = ""
    var name = ""
    var number:Int!
    var floorName = ""
    var desc = ""
    var type = ""
    var type_zh = ""
    var icon: [[String:String]] = []
    var lat: Double!
    var lng: Double!
    var coordinate: CLLocationCoordinate2D!
    var distance: String!
    
    
    init(data: [String: Any]) {
        id = getIntFromJSON(data: data, key: "id")
        aac_id = getIntFromJSON(data: data, key: "aac_id")
        ac_id = getIntFromJSON(data: data, key: "ac_id")
        puid = getStringFromJSON(data: data, key: "puid")
        name = getStringFromJSON(data: data, key: "name")
        number = getIntFromJSON(data: data, key: "number")
        desc = getStringFromJSON(data: data, key: "desc")
        type = getStringFromJSON(data: data, key: "type")
        type_zh = getStringFromJSON(data: data, key: "type_zh")
        icon = getStrDicArrayFromJSON(data: data, key: "icon")
        lat = getDoubleFromJSON(data: data, key: "lat")
        lng = getDoubleFromJSON(data: data, key: "lng")
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        distance = getStringFromJSON(data: data, key: "distance")
    }
}

struct OGCategoryModel {
    let ac_id: Int
    let title_zh: String
    let title_en: String
    let enabled: Bool
    
    init(_ dic: [String: Any]) {
        ac_id = dic["ac_id"] as? Int ?? 0
        title_zh = dic["title_zh"] as? String ?? ""
        title_en = dic["title_en"] as? String ?? ""
        enabled = (dic["enabled"] as? String ?? "N") == "Y"
    }
}
