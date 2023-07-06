//
//  PlanModel.swift

import Foundation

struct PlanModel: JSONEnable {
    var id: Int!
    var number: Int!
    var name = ""
    var desc = ""
    var order = ""
    var lat: Double!
    var lng: Double!
    var bl_lat: Double!
    var bl_lng: Double!
    var tr_lat: Double!
    var tr_lng: Double!
    var plan_id = ""
    var is_map = ""
    var pois: [OGPointModel] = []
    
    init(data: [String: Any]) {
        id = getIntFromJSON(data: data, key: "id")
        number = getIntFromJSON(data: data, key: "number")
        name = getStringFromJSON(data: data, key: "name")
        desc = getStringFromJSON(data: data, key: "desc")
        order = getStringFromJSON(data: data, key: "order")
        lat = getDoubleFromJSON(data: data, key: "lat")
        lng = getDoubleFromJSON(data: data, key: "lng")
        bl_lat = getDoubleFromJSON(data: data, key: "bl_lat")
        bl_lng = getDoubleFromJSON(data: data, key: "bl_lng")
        tr_lat = getDoubleFromJSON(data: data, key: "tr_lat")
        tr_lng = getDoubleFromJSON(data: data, key: "tr_lng")
        plan_id = getStringFromJSON(data: data, key: "plan_id")
        is_map = getStringFromJSON(data: data, key: "is_map")
        
        let pois = getArrayFromJSON(data: data, key: "pois")
        
        pois.forEach({
            if let data = $0 as? [String: Any] {
                let poi = OGPointModel(data: data)
                poi.number = number
                poi.floorName = name
                self.pois.append(poi)
            }
        })
    }
}

struct NaviModel: JSONEnable {
    var lat: String!
    var lon: String!
    var floor_number: String!
    var angle: Double!
    
    init(data: [String: Any]) {
        self.lat = getStringFromJSON(data: data, key: "lat")
        self.lon = getStringFromJSON(data: data, key: "lon")
        self.floor_number = getStringFromJSON(data: data, key: "floor_number")
    }
}
