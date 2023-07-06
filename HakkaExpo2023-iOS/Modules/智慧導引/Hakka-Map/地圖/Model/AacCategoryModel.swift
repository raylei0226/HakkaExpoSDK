//
//  AacCategoryModel.swift
//  NAVISDK
//
//  Created by Jelico on 2021/5/20.
//

import Foundation


struct AacCategoryModel: JSONEnable {
    var aac_id: Int!
    var ac_id: Int!
    var category = ""
    var category_en = ""
    var list: [AcCategoryModel] = []
    
    init(data: [String: Any]) {
        aac_id = getIntFromJSON(data: data, key: "aac_id")
        ac_id = getIntFromJSON(data: data, key: "ac_id")
        category = getStringFromJSON(data: data, key: "category")
        category_en = getStringFromJSON(data: data, key: "category_en")
        
        let listData = getDicArrayFromJSON(data: data, key: "list")
        listData.forEach({
            list.append(AcCategoryModel(data: $0))
        })
    }
}
