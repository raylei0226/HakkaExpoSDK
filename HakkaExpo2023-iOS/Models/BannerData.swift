//
//  BannerData.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/1.
//


struct BannerData: Codable {
    var result, message: String?
    var data: [BannerInfo]?
}

struct BannerInfo: Codable {
    var bID: Int?
    var bTitle: String?
    var bYoutube: String?
    var bImage, bImageMobile: String?
    var bURL: String?
    var bNewpage, bBeginTimestamp, bEndTimestamp: String?
    var bOrder: Int?

    enum CodingKeys: String, CodingKey {
        case bID = "b_id"
        case bTitle = "b_title"
        case bYoutube = "b_youtube"
        case bImage = "b_image"
        case bImageMobile = "b_image_mobile"
        case bURL = "b_url"
        case bNewpage = "b_newpage"
        case bBeginTimestamp = "b_begin_timestamp"
        case bEndTimestamp = "b_end_timestamp"
        case bOrder = "b_order"
    }
}
