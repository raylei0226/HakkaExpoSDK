//
//  APIEndpoint.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/31.
//

import Foundation

enum APIEndPoint {
    case getTopBanner
    case getPano360
    case getMissionOrReward
    case getNineGrid
    
    
    var baseURL: String {
        return "https://hakkaexpo-test.omniguider.com"
    }
    
    var path: String {
        switch self {
        case .getTopBanner: return "/webapi/get_top_banner"
        case .getPano360: return "/api/get_pano360"
        case .getMissionOrReward: return "/api/get_mission"
        case .getNineGrid: return "/api/get_nine_grid"

        }
    }
    
    var url: URL? {
        return URL(string: baseURL + path)
    }
}
