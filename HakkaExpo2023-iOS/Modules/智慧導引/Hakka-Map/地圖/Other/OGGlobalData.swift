//
//  OGGlobalData.swift
//  OmniGuiderFramework
//
//  Created by 李東儒 on 2021/2/2.
//

import Foundation
import UIKit

class OGGlobalData {
    static var finishDownload = false
    static let shared = OGGlobalData()
    static let floorProvider = OGFloorProvider()
    static let pointProvider = OGPointProvider()
    
    func setFloorPointData(_ data: [[String: Any]], completionHandler: (()->())?) {
        OGGlobalData.floorProvider.floors.removeAll()
        
        for floor in data {
            OGGlobalData.floorProvider.add(floor)
            
            if let pois = floor["pois"] as? [[String: Any]] {
                let number = floor["number"] as? Int
                
                for poi in pois {
                    var point = poi
                    point["number"] = number
                    OGGlobalData.pointProvider.add(point)
                }
            }
        }
        OGGlobalData.finishDownload = true
        
        if let completionHandler = completionHandler {
            completionHandler()
        }
    }
}
