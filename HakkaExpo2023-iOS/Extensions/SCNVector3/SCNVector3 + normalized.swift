//
//  SCNVector3 + normalized.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/7/7.
//

import Foundation
import SceneKit

extension SCNVector3 {
    func normalized() -> SCNVector3 {
        let length = sqrt(x * x + y * y + z * z)
        return SCNVector3(x / length, y / length, z / length)
    }
}
