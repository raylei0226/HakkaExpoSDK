//
//  OGMarker.swift
//  NAVISDK
//
//  Created by Jelico on 2021/12/31.
//

import Foundation
import GoogleMaps

class OGMarker: GMSMarker {
    let dateFormstter = DateFormatter()

    override init() {
        dateFormstter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
    }
    
    func recordPosition() {
        let timeMark = dateFormstter.string(from: Date())
        let lat = Float(position.latitude)
        let lng = Float(position.longitude)
        let newPosition = "\(timeMark) \(lat) \(lng)"
        var positions = NaviUtility.GetUserValue(by: .userMarkerPosition) as? String ?? ""
      
        if CountOver(5000, in: positions) {
            NaviUtility.DeleteUserValue(by: .userMarkerPosition)
            positions = ""
        }
        positions += "\(newPosition),"
        NaviUtility.SaveUserValue(key: .userMarkerPosition, value: positions)
    }
}
