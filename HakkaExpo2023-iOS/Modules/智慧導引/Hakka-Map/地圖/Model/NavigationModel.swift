//
//  NavigationModel.swift
//  NAVISDK
//
//  Created by Jimmy Zhong on 2019/11/26.
//  Copyright © 2019 omniguider. All rights reserved.
//

import Foundation
import CoreLocation

struct NavModel {
    var distance = 0.0
    var duration = 0
    var localizedGoStation = ""
    var localizedEndStation = ""
    var localizedTnTitle = ""
    var localizedTrTitle = ""
    var traffic_wait_min = 0
    var traffic_start_time = ""
    var traffic_end_time = ""
    var traffic_duration = 0
    var tool_type = NavStep.ToolType.walk
    var steps = [NavStep]()
    
    init(_ dic: [String: Any]) {
        guard
            let overview = dic["overview"] as? [String: Any],
            let step = dic["step"] as? [[String: Any]]
        else {
            steps.append(NavStep(dic))
            return
        }
        let type = overview["tool_type"] as? String ?? ""
        tool_type = NavStep.ToolType(rawValue: type) ?? .walk
        distance = overview["distance"] as? Double ?? 0.0
        duration = overview["duration"] as? Int ?? 0
        localizedGoStation = Localizer.apiDic(overview, key: "go_station")
        localizedEndStation = Localizer.apiDic(overview, key: "end_station")
        localizedTnTitle = Localizer.apiDic(overview, key: "tn_title")
        localizedTrTitle = Localizer.apiDic(overview, key: "tr_title")
        traffic_wait_min = overview["traffic_wait_min"] as? Int ?? 0
        traffic_duration = overview["traffic_duration"] as? Int ?? 0
        traffic_start_time = String((overview["traffic_start_time"] as? String ?? "").dropLast(3))
        traffic_end_time = String((overview["traffic_end_time"] as? String ?? "").dropLast(3))
        
        for stepDic in step {
            steps.append(NavStep(stepDic))
        }
    }
}

struct NavStep {
    
    enum ToolType:String {case walk = "walk", bus = "bus", train = "train"}
    
    let toolType: ToolType
    let path_distance: Double
    let path_time_minutes: Double
    let duration: Int
    var points = [NavPoint]()
    var stationNames = [String]()
    
    init(_ dic: [String: Any]) {
        let tool_type = dic["tool_type"] as? String ?? ""
        toolType = ToolType(rawValue: tool_type) ?? .walk
        path_distance = dic["path_distance"] as? Double ?? 0.0
        duration = dic["duration"] as? Int ?? 0
        path_time_minutes = dic["path_time_minutes"] as? Double ?? 0
        guard let poiDics = dic["pois"] as? [[String: Any]], poiDics.count >= 2 else {
            return
        }
        var degree = 0.0
        for index in 0..<poiDics.count - 1 {
            var current = NavPoint(poiDics[index])
            if current.lat == 0 || current.lng == 0 {
                continue
            }
            if toolType != .walk && current.name != "Connector" {
                stationNames.append(current.name)
            }
            degree += current.degree
            if degree > 5 || degree < -5 {
                current.setDirection(with: degree)
                degree = 0.0
                points.append(current)
            }
        }
        let last = NavPoint(poiDics.last!)
        stationNames.append(last.name)
        points.append(last)
    }
}

struct NavPoint {
    
    enum Direction {case right, slightRight, left, slightLeft, end, alongStraight}
    var direction = Direction.end
    
    let name: String
    let lat: Double
    let lng: Double
    var distance: Double
    var degree: Double

    init(_ dic: [String: Any]) {
        name = dic["name"] as? String ?? "Connector"
        lat = Double(dic["lat"] as? String ?? "0") ?? 0.0
        lng = Double(dic["lon"] as? String ?? "0") ?? 0.0
        distance = dic["distance"] as? Double ?? 0.0
        degree = dic["degree"] as? Double ?? 0.0
    }
    
    mutating func setDirection(with degree: Double) {
        switch degree {
        case -360...(-20):
            direction = .right
        case -20...(-5):
            direction = .slightRight
        case 5...20:
            direction = .slightLeft
        case 20...360:
            direction = .left
        default:
            break
        }
        self.degree = degree
    }
    
    func distance(to otherPoint: NavPoint) -> Double {
        let location = CLLocation(latitude: lat, longitude: lng)
        let otherLocation = CLLocation(latitude: otherPoint.lat, longitude: otherPoint.lng)
        return location.distance(from: otherLocation)
    }
}
