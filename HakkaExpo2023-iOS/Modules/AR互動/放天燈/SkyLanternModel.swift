//
//  SkyLanternModel.swift
//  OmniArTaipei
//
//  Created by Dong on 2022/11/23.
//

import Foundation
import CoreLocation

//MARK: - FirebaseReference
struct FirebaseOmniAnchorModel {
    var anchor = [String: FirebaseAnchor]()
    
    init(_ dic: [String: Any]) {
        for key in dic.keys {
            if let anchorValue = dic[key] as? [String: Any] {
                let value = FirebaseAnchor(anchorValue)
                anchor[key] = value
            }
        }
    }
    
    func timestamp(at key: String) -> Double {
        guard let selectedAnchor = anchor[key] else {return Date().timeIntervalSince1970}
        return selectedAnchor.timestamp 
    }
}

struct FirebaseAnchor {
    let shortKey: String
    let latitude: Double
    let longitude: Double
    let timestamp: Double
    
    init(_ dic: [String: Any]) {
        shortKey = dic["shortKey"] as? String ?? ""
        latitude = dic["latitude"] as? Double ?? 0
        longitude = dic["longitude"] as? Double ?? 0
        timestamp = (dic["timestamp"] as? Double ?? 0) / 1000
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
