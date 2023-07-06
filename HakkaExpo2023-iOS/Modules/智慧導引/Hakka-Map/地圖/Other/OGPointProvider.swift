//
//  OGPointProvider.swift
//  OmniGuiderFramework
//
//  Created by 李東儒 on 2021/2/2.
//

import Foundation

class OGPointProvider {
    var points = [OGPointModel]()
    
    func add(_ point: [String: Any]) {
        points.append(OGPointModel(data: point))
    }
    
    func count() -> Int {
        return points.count
    }
    
    func getAll() -> [OGPointModel] {
        return points
    }
    
    func get(at id: Int) -> OGPointModel? {
        return points.filter({$0.id == id}).first
    }
    
    func get(atFloorId floorId: Int) -> [OGPointModel] {
        return points.filter({$0.number == floorId})
    }
    
    func get(atAcId acId: Int) -> [OGPointModel] {
        return points.filter({$0.ac_id == acId})
    }
}
