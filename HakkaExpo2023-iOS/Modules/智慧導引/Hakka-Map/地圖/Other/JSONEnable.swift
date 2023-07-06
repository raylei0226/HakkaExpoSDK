//
//  JSONEnable.swift

import Foundation
import CoreLocation

protocol JSONEnable {}

extension JSONEnable {
    func getIntFromJSON(data: [String: Any], key: String) -> Int {
        if let int = data[key] as? Int {
            return int
        }else if let info = data[key] as? String {
            let int = Int(info) ?? 0
            return int
        }else {
            return 0
        }
    }
    
    func getDoubleFromJSON(data: [String: Any], key: String) -> Double {
        let info = data[key] as? Double ?? 0.0
        return info
    }
    
    func getStringFromJSON(data: [String: Any], key: String) -> String {
        let info = data[key] as? String ?? ""
        return info
    }
    
    func getBoolFromJSON(data: [String: Any], key: String, status: Bool) -> Bool {
        let info = data[key] as? Bool ?? status
        return info
    }
    
    func getArrayFromJSON(data: [String: Any], key: String) -> [Any] {
        let array = data[key] as? [Any] ?? []
        return array
    }
    
    func getStringArrayFromJSON(data: [String: Any], key: String) -> [String] {
        let array = data[key] as? [String] ?? []
        return array
    }
    
    func getIntArrayFromJSON(data: [String: Any], key: String) -> [Int] {
        let array = data[key] as? [Int] ?? []
        return array
    }
    
    func getStrDicArrayFromJSON(data: [String: Any], key: String) -> [[String: String]] {
        let array = data[key] as? [[String: String]] ?? []
        return array
    }

    
    func getDictionaryFromJSON(data: [String: Any], key: String) -> [String: Any] {
        let dic = data[key] as? [String: Any] ?? [:]
        return dic
    }
    
    func getDicArrayFromJSON(data: [String: Any], key: String) -> [[String: Any]] {
        let dicArr = data[key] as? [[String: Any]] ?? []
        return dicArr
    }

    func getLocationFromJSON(data: [String: Any], key: String) -> CLLocation {
        let info = data[key] as! CLLocation
        return info
    }

    func getCoordinateFromJSON(data: [String: Any], key: String) -> CLLocationCoordinate2D {
        let info = data[key] as! CLLocationCoordinate2D
        return info
    }
}
