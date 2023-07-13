//
//  MissionStatusModel.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/19.
//

struct MissionStatusData: Codable {
    var result, errorMessage: String?
    var data: StatusInfoData?

    enum CodingKeys: String, CodingKey {
        case result
        case errorMessage = "error_message"
        case data
    }
}

struct StatusInfoData: Codable {
    var status: String?
    var statusCode: Int?
    var missionStatus: String?
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case statusCode = "status_code"
        case missionStatus = "mission_status"
        case message
    }
}
