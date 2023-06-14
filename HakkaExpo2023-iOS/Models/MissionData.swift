//
//  MissionData.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/14.
//

struct MissionData: Codable {
    var result, errorMessage: String?
    var data: [MissionInfoData]?

    enum CodingKeys: String, CodingKey {
        case result
        case errorMessage = "error_message"
        case data
    }
}

struct MissionInfoData: Codable {
    var mID, mTitle, mDescribe: String?
    var mImg: String?
    var mMinPassCount, mStartTime, mEndTime, mEnabled: String?
    var rwRemaining, rwExpiredStartTime, rwExpiredEndTime: String?
    var isFinish: Bool?
    var rwsEnabled, verifyCode: String?
    
    enum CodingKeys: String, CodingKey {
        case mID = "m_id"
        case mTitle = "m_title"
        case mDescribe = "m_describe"
        case mImg = "m_img"
        case mMinPassCount = "m_min_pass_count"
        case mStartTime = "m_start_time"
        case mEndTime = "m_end_time"
        case mEnabled = "m_enabled"
        case rwRemaining = "rw_remaining"
        case rwExpiredStartTime = "rw_expired_start_time"
        case rwExpiredEndTime = "rw_expired_end_time"
        case isFinish = "is_finish"
        case rwsEnabled = "rws_enabled"
        case verifyCode = "verify_code"
    }
}
