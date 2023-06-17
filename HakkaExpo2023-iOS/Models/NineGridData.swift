//
//  NineGridData.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/15.
//


struct NineGridData: Codable {
    var result, errorMessage: String?
    var data: GridInfoData?

    enum CodingKeys: String, CodingKey {
        case result
        case errorMessage = "error_message"
        case data
    }
}

struct GridInfoData: Codable {
    var gridNow: Int?
    var isFinish: Bool?
    var nineGrid: [NineGrid]?
    var missionTitle, missionDescribe, missionEndTime, rwsEnabled: String?
    var rewardName, rewardRemainng: String?

    enum CodingKeys: String, CodingKey {
        case gridNow = "grid_now"
        case isFinish = "is_finish"
        case nineGrid = "nine_grid"
        case missionTitle = "mission_title"
        case missionDescribe = "mission_describe"
        case missionEndTime = "mission_end_time"
        case rwsEnabled = "rws_enabled"
        case rewardName = "reward_name"
        case rewardRemainng = "reward_remainng"
    }
}

struct NineGrid: Codable {
    var id, title, description, notice: String?
    var image: String?
    var triggerDistance, passMethod: String?
    var beacon: Beacon?
    var question: Question?
    var isComplete: Bool?

    enum CodingKeys: String, CodingKey {
        case id, title, description, notice, image
        case triggerDistance = "trigger_distance"
        case passMethod = "pass_method"
        case beacon, question
        case isComplete = "is_complete"
    }
}

struct Beacon: Codable {
    var id, description, major, minor: String?
    var hwid, mac, lat, lng: String?
    var range: String?
}

struct Question: Codable {
    var style, type, title: String?
    var image: String?
    var video: JSONNull?
    var option1, option2, option3, option4: String?
    var answer, tip: String?
}

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}


