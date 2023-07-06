//
//  GetFloorData.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/7/3.
//


struct GetFloorData: Codable {
    var result, errorMessage: String?
    var data: [FloorData]?

    enum CodingKeys: String, CodingKey {
        case result
        case errorMessage = "error_message"
        case data
    }
}

struct FloorData: Codable {
    var id, number: Int?
    var name, desc, order: String?
    var lat, lng, blLat, blLng: Double?
    var trLat, trLng: Double?
    var planID: String?
    var isMap: Bool?
    var pois: [Pois]?

    enum CodingKeys: String, CodingKey {
        case id, number, name, desc, order, lat, lng
        case blLat = "bl_lat"
        case blLng = "bl_lng"
        case trLat = "tr_lat"
        case trLng = "tr_lng"
        case planID = "plan_id"
        case isMap = "is_map"
        case pois
    }
}

struct Pois: Codable {
    var id: Int?
    var name, placeName: String?
    var number, aacID, acID: Int?
    var lat, lng: Double?
    var distance: String?
    var isIndoor: Bool?
    var information: Information?

    enum CodingKeys: String, CodingKey {
        case id, name
        case placeName = "place_name"
        case number
        case aacID = "aac_id"
        case acID = "ac_id"
        case lat, lng, distance
        case isIndoor = "is_indoor"
        case information
    }
}

struct Information: Codable {
    var image: String?
}
