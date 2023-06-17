import UIKit
import Alamofire

struct HttpsParameters {
    
    func getTimeStamp() -> Parameters
    {
        let now = Date()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let time = "\(Configs.encryptToken)" + "\(timeStamp)"
        
        if let mac = time.sha1 {
            let parameters: Parameters = ["timestamp": timeStamp, "mac": mac, "lang": "zh"]
            return parameters
        }
        return [:]
    }
    
    
    func getTimeStampWithoutLang() -> Parameters
    {
        let now = Date()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let time = "\(Configs.encryptToken)" + "\(timeStamp)"
        
        if let mac = time.sha1 {
            let parameters: Parameters = ["timestamp": timeStamp, "mac": mac]
            return parameters
        }
        return [:]
    }
    
    
    
    func getTimeStampAndDevice() -> Parameters
    {
        let deviceID = DeviceIDManager.shared.getDeviceID()
        var parameters: Parameters = getTimeStamp()
        parameters["u_id"] = deviceID
        
        return parameters
    }
    
    func getTimeStampAndDeviceWithoutLang() -> Parameters {
        let deviceID = DeviceIDManager.shared.getDeviceID()
        var parameters: Parameters = getTimeStampWithoutLang()
        parameters["u_id"] = deviceID
        
        return parameters
    }
    
}

