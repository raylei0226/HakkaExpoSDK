//
//  CategoryModel.swift
//  NAVISDK
//
//  Created by Jelico on 2021/3/22.
//

import Foundation

struct AcCategoryModel: JSONEnable {
    var ac_id: Int!
    var title_zh = ""
    var title_en = ""
    var enabled = ""
    
    init(data: [String: Any]) {
        ac_id = getIntFromJSON(data: data, key: "ac_id")
        title_zh = getStringFromJSON(data: data, key: "title_zh")
        title_en = getStringFromJSON(data: data, key: "title_en")
        enabled = getStringFromJSON(data: data, key: "enabled")
    }
}
