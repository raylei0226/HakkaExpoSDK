//
//  DeviceIDManager.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/19.
//

import UIKit
import Security

class DeviceIDManager {
    
    static let shared = DeviceIDManager()
    
    private init() {}
    
    let deviceIDKey = "deviceUUID"
    
    func getDeviceID() -> String {
        if let deviceID = loadDeviceID() {
            return deviceID
        }
        
        let newDeviceID = UUID().uuidString
        saveDeviceID(newDeviceID)
        return newDeviceID
    }
    
    private func saveDeviceID(_ deviceID: String) {
        if let data = deviceID.data(using: .utf8) {
            _ = KeychainManager.shared.save(key: deviceIDKey, data: data)
        }
    }
    
    private func loadDeviceID() -> String? {
        if let data = KeychainManager.shared.load(key: deviceIDKey) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func deleteDeviceID() {
        _ = KeychainManager.shared.delete(key: deviceIDKey)
    }
}
