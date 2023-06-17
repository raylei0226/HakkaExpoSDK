//
//  AwardTicketData.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/16.
//

//TicketData

struct AwardTicketData: Codable {
    var result, errorMessage: String?
    var data: [TicketData]?

    enum CodingKeys: String, CodingKey {
        case result
        case errorMessage = "error_message"
        case data
    }
}

struct TicketData: Codable {
    var mID, rwID, mTitle: String?
    var mImg: String?
    var mMinPassCount, rwTitle: String?
    var rwImg: String?
    var rwDescribe, rwNum, rwRemaining, rwNotice: String?
    var rwExpiredEndTime, rwExpiredStartTime: String?
    var isFinish: Bool?
    var rwsEnabled, verifyCode: String?

    enum CodingKeys: String, CodingKey {
        case mID = "m_id"
        case rwID = "rw_id"
        case mTitle = "m_title"
        case mImg = "m_img"
        case mMinPassCount = "m_min_pass_count"
        case rwTitle = "rw_title"
        case rwImg = "rw_img"
        case rwDescribe = "rw_describe"
        case rwNum = "rw_num"
        case rwRemaining = "rw_remaining"
        case rwNotice = "rw_notice"
        case rwExpiredEndTime = "rw_expired_end_time"
        case rwExpiredStartTime = "rw_expired_start_time"
        case isFinish = "is_finish"
        case rwsEnabled = "rws_enabled"
        case verifyCode = "verify_code"
    }
}
