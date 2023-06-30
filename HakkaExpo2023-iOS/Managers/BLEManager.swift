//
//  BLEManager.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/28.
//

import CoreBluetooth
import UIKit

protocol BLEManagerDelegate: AnyObject {
    func didDiscoverServiceData(_ hwid: String)
}

class BLEManager: NSObject {
    
    static let instance = BLEManager()
    
    private var centralManager: CBCentralManager!
    
    weak var delegate: BLEManagerDelegate?
    
    var connectedPeripheral: CBPeripheral?
    
    private override init() {
        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        let options: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        centralManager.scanForPeripherals(withServices: nil, options: options)
        HudManager.shared.showSuccess(withMessage: "開始掃描")
    }
    
    func connect(peropheral: CBPeripheral) {
        connectedPeripheral = peropheral
        centralManager.connect(connectedPeripheral!, options: nil)
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    
    //前往設定開啟藍芽
    func toSetting() {
        let alert = UIAlertController(title: "藍牙未開啟", message: "是否更改設定?", preferredStyle: .alert)
        let settingAction = UIAlertAction(title: "設定", style: .default) { (_) -> Void in
            let first = "App-prefs:" , last = "Bluetooth"
            guard let settingURL = URL(string: first + last) else { return }
            if UIApplication.shared.canOpenURL(settingURL) {
                UIApplication.shared.open(settingURL, completionHandler: nil)
            }
        }
        alert.addAction(settingAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        if var topViewController = keyWindow?.rootViewController {
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            topViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func toAppAuthorized() {
        let alert = UIAlertController(title: "未給予裝置藍牙權限", message: "是否更改設定?", preferredStyle: .alert)
        let settingAction = UIAlertAction(title: "設定", style: .default) { (_) -> Void in
            guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingURL) {
                UIApplication.shared.open(settingURL, completionHandler: nil)
            }
        }
        alert.addAction(settingAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        if var topViewController = keyWindow?.rootViewController {
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            topViewController.present(alert, animated: true, completion: nil)
        }
    }
}

extension BLEManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
            
        case .poweredOff:
            toSetting()
        case .unauthorized:
            toAppAuthorized()
        case .unknown, .resetting, .unsupported:
            HudManager.shared.showError(withMessage: "不支援該裝置")
        case .poweredOn:
            print("BT On")
            startScan()
            
        @unknown default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
//        guard peripheral.name == "ATM tag" else { return }
        
        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] {
            for (serviceUUID, data) in serviceData {
                if serviceUUID == Configs.LineBeaconServiceUUID {
                        let hwID = data[1...5].hexString()
                        delegate?.didDiscoverServiceData(hwID)
                }
            }
        }
    }
}
