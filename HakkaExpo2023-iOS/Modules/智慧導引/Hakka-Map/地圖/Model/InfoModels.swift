//
//  InfoModels.swift
//  NAVISDK
//
//  Created by Jimmy Zhong on 2019/10/7.
//  Copyright © 2019 omniguider. All rights reserved.
//

import Foundation
import GoogleMaps

struct InfoFloor {
    let id: Int
    let number: Int
    let name: String
    let plan_id: String
    
    init(with dic: [String: Any]) {
        self.id = dic["id"] as? Int ?? 0
        self.number = dic["number"] as? Int ?? 0
        self.name = dic["name"] as? String ?? ""
        self.plan_id = dic["plan_id"] as? String ?? ""
    }
}

struct InfoType {
    let aac_id: Int
    let localizedTitle: String
    let aac_image: String
    let aac_bg_color: String
    var subTypes = [Int]()
    var points = [Int]()
    
    init(with dic: [String: Any]) {
        self.aac_id = dic["aac_id"] as? Int ?? 0
        self.localizedTitle = Localizer.apiDic(dic, key: "aac_title")
        self.aac_image = dic["aac_image"] as? String ?? ""
        self.aac_bg_color = dic["aac_bg_color"] as? String ?? ""
    }
    
    mutating func addSubType(id: Int) {
        subTypes.append(id)
    }
    
    mutating func addPoint(id: Int) {
        points.append(id)
    }
}


struct InfoSubType {
    let ac_id: Int
    let localizedTitle: String
    let ac_title_en: String
    let ac_image: String
    
    init(with dic: [String: Any]) {
        self.ac_id = dic["ac_id"] as? Int ?? 0
        self.localizedTitle = Localizer.apiDic(dic, key: "ac_title")
        self.ac_title_en = dic["ac_title_en"] as? String ?? ""
        self.ac_image = dic["ac_image"] as? String ?? ""
    }
}

struct InfoPoint {
    var noContent: Bool {
        return localizedInfo == "" && localizedDesc == "" && localizedAudio == "" && localizedVideo == "" && address == "" && web == "" && tel == "" && opentime == ""
    }
    
    let p_id: Int
    let ac_id: Int
    let localizedName: String
    var min_level: Float = 20
    let max_level: Float = 22
    let lat: Double
    let lng: Double
    let image: String
    let localizedInfo: String
    let localizedDesc: String
    let localizedAudio: String
    let localizedVideo: String
    let address: String
    let web: String
    let tel: String
    let opentime: String
    
    var distance = 0
    
    init(with dic: [String: Any]) {
        self.p_id = dic["p_id"] as? Int ?? 0
        self.ac_id = dic["ac_id"] as? Int ?? 0
        self.localizedName = Localizer.apiDic(dic, key: "name")
        self.lat = dic["lat"] as? Double ?? 0.0
        self.lng = dic["lng"] as? Double ?? 0.0
        // Setup Level
        let poi_level = dic["poi_level"] as? Int ?? 0
        let levels:[Int:Float] = [1:kGMSMinZoomLevel, 2:15, 3:16, 4:17, 5:18]
        self.min_level = levels[poi_level] ?? kGMSMinZoomLevel
        // Details
        self.image = dic["image"] as? String ?? ""
        self.localizedInfo = Localizer.apiDic(dic, key: "info")
        self.localizedDesc = Localizer.apiDic(dic, key: "desc")
        self.localizedAudio = Localizer.apiDic(dic, key: "audio")
        self.localizedVideo = Localizer.apiDic(dic, key: "video")
        self.address = dic["address"] as? String ?? ""
        self.web = dic["web"] as? String ?? ""
        self.tel = dic["tel"] as? String ?? ""
        self.opentime = dic["opentime"] as? String ?? ""
    }
    
    mutating func calcDistance(to location: CLLocation) {
        let myLocation = CLLocation(latitude: lat, longitude: lng)
        distance = Int(myLocation.distance(from: location))
    }
}

struct InfoMapText {
    
    let name: String
    let color: String
    let min_level: Float
    let max_level: Float
    let lat: Double
    let lng: Double
    
    init(with dic: [String: Any]) {
        self.name = dic["name"] as? String ?? ""
        self.color = dic["color"] as? String ?? ""
        self.min_level = Float(dic["min_level"] as? Int ?? 0)
        self.max_level = Float(dic["max_level"] as? Int ?? 0)
        self.lat = dic["lat"] as? Double ?? 0.0
        self.lng = dic["lng"] as? Double ?? 0.0
    }
}
