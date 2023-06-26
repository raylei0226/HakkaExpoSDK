//
//  ResponseData.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/19.
//

struct ResponseData: Codable {
    var result, errorMessage, data: String
    
    enum CodingKeys: String, CodingKey {
        case result
        case errorMessage = "error_message"
        case data
    }
}
