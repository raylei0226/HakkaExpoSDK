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
    
    func getTimeStampAndDevice() -> Parameters
    {
        let identifierForVendor = UIDevice.current.identifierForVendor
        let deviceId = (identifierForVendor?.uuidString)!
        let uuid = "&device_id=\(deviceId)"
        
        var parameters: Parameters = getTimeStamp()
        parameters["device_id"] = deviceId
        
        return parameters
    }
}

