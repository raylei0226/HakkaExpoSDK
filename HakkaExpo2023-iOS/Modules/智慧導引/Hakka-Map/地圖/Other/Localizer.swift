//
//  Localizer.swift
//  AliShan
//
//  Created by Jimmy Zhong on 2019/10/7.
//  Copyright © 2019 omniguider. All rights reserved.
//

import Foundation
import UIKit

class Localizer {
    
    enum LanguageType {case zh, cn, en}

    static func apiDic(_ dic: [String: Any], key: String) -> String {
        let normal = dic[key] as? String ?? ""
        let normal_zh = dic[key + "_zh"] as? String ?? ""
        let string_zh = normal == "" ? normal_zh : normal
        var localizedString = ""
        switch Locale.preferredLanguages.first?.languageCodeWithoutRegion {
        case "en":
            localizedString = dic[key + "_en"] as? String ?? ""
        case "zh-Hans":
            localizedString = dic[key + "_cn"] as? String ?? ""
        default:
            return string_zh
        }
        return localizedString == "" ? string_zh : localizedString
    }
    
    static func image(name: String) -> UIImage? {
        var imageName = name
        switch Locale.preferredLanguages.first?.languageCodeWithoutRegion {
        case "en":
            imageName += "_en"
        case "zh-Hans":
            imageName += "_cn"
        default:
            imageName += "_zh"
        }
        return UIImage(named: imageName)
    }
    
    static func preferredLanguage() -> LanguageType {
        guard let languages = Locale.preferredLanguages.first else {
            return LanguageType.zh
        }
        if languages.contains("en") {
            return LanguageType.en
        }else if languages.contains("zh-Hans") {
            return LanguageType.cn
        }else {
            return LanguageType.zh
        }
    }
}
