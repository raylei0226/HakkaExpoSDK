//
//  APIEndpoint.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/31.
//

import Foundation

enum APIEndPoint {
    case getTopBanner
    
    
    var baseURL: String {
        return "https://hakkaexpo-test.omniguider.com"
    }
    
    var path: String {
        switch self {
        case .getTopBanner: return "/webapi/get_top_banner"
        }
    }
    
    var url: URL? {
        return URL(string: baseURL + path)
    }
}
