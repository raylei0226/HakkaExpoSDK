//
//  OGFloorProvider.swift
//  OmniGuiderFramework
//
//  Created by 李東儒 on 2021/2/2.
//

import Foundation

typealias OGFloorInfo = (number: Int, id: Int, name: String)

class OGFloorProvider {
    var floors = [OGFloorModel]()
    
    func add(_ floor: [String: Any]) {
        floors.append(OGFloorModel(floor))
    }
    
    func count() -> Int {floors.count}
    
    func getAll() -> [OGFloorModel] {
        return floors
    }
    
    func get(at id: Int) -> OGFloorModel? {
        return floors.filter({$0.id == id}).first
    }
    
    func getAllNumber() -> [Int] {
        var numbers = [Int]()
        floors.forEach({numbers.append($0.number)})
        return numbers
    }
    
    func getAllFloorInfo() -> [OGFloorInfo] {
        var infos = [OGFloorInfo]()
        floors.forEach({infos.append(($0.number, $0.id, $0.name))})
        return infos
    }
}
