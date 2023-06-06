//
//  PanoramaData.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/5.
//

struct PanoramaData: Codable {
    var result, message: String?
    var data: [PanoInfo]?
}

struct PanoInfo: Codable {
    var name, url, image, sort: String?
}
