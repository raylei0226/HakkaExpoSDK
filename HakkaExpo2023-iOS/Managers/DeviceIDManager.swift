//
//  DeviceIDManager.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/19.
//

import UIKit


//取得裝置UUID
struct DeviceIDManager {
    
    static func getDeviceID() -> String {
        
        let deviceIDKey = Configs.UserDefaultsKeys.deviceUUID
        
        if let storedDeviceID = UserDefaults.standard.string(forKey: deviceIDKey) {
            return storedDeviceID
        } else {
            let newDebiceID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            UserDefaults.standard.set(newDebiceID, forKey: deviceIDKey)
            return newDebiceID
            
        }
    }
}
