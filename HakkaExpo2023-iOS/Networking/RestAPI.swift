//
//  API.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/22.
//

import Foundation
import Alamofire

class RestAPI {
    
    static let shared = RestAPI()
    
    private init() {}
    
    
    func getTopBanner(completion: @escaping (BannerData?) -> Void) {
        
        let parameters = HttpsParameters().getTimeStamp()
        
        logParameters(functionName: #function, parameters: parameters)
        
        NetworkManager.shared.request(endpoint: APIEndPoint.getTopBanner, method: .post, parameters: parameters) { (result: Result<BannerData, Error>) in
            
            switch result {
            case .success(let decodedData):
                completion(decodedData)
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    
    func getPano360(completion: @escaping (PanoramaData?) -> Void) {
        
        let parameters = HttpsParameters().getTimeStamp()
        
        logParameters(functionName: #function, parameters: parameters)
        
        NetworkManager.shared.request(endpoint: APIEndPoint.getPano360, method: .post, parameters: parameters) { (result: Result<PanoramaData, Error>) in
            
            switch result {
            case .success(let decodedData):
                completion(decodedData)
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    func getMission(_ apiType: MissionApiType.RawValue, completion: @escaping(MissionData?) -> Void) {
        
        var parameters = HttpsParameters().getTimeStampAndDeviceWithoutLang()
        parameters["type"] = apiType
        
        logParameters(functionName: #function, parameters: parameters)
        
        NetworkManager.shared.request(endpoint: APIEndPoint.getMissionOrReward, method: .post, parameters: parameters) { (result: Result<MissionData, Error>) in
            switch result {
            case .success(let decodedData):
                completion(decodedData)
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    func getAward(_ apiType: MissionApiType.RawValue, completion: @escaping(AwardTicketData?) -> Void) {
        
        var parameters = HttpsParameters().getTimeStampAndDeviceWithoutLang()
        parameters["type"] = apiType
        
        logParameters(functionName: #function, parameters: parameters)
        
        NetworkManager.shared.request(endpoint: APIEndPoint.getMissionOrReward, method: .post, parameters: parameters) { (result: Result<AwardTicketData, Error>) in
            switch result {
            case .success(let decodedData):
                completion(decodedData)
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    func getNineGrid(_ missionID: String, completion: @escaping(NineGridData?) -> Void)  {
        
        var parameters = HttpsParameters().getTimeStampAndDeviceWithoutLang()
        parameters[K.missionID] = missionID
        
        logParameters(functionName: #function, parameters: parameters)
        
        NetworkManager.shared.request(endpoint: APIEndPoint.getNineGrid, method: .post, parameters: parameters) { (result: Result<NineGridData, Error>) in
            switch result {
            case .success(let decodedData):
                completion(decodedData)
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    func getMissionComplete(_ missionID: String, _ gridID: String, completion: @escaping(MissionStatusData?) -> Void) {
        
        var parameters = HttpsParameters().getTimeStampAndDeviceWithoutLang()
        parameters[K.missionID] = missionID
        parameters[K.gridID] = gridID
        
        logParameters(functionName: #function, parameters: parameters)
        
        NetworkManager.shared.request(endpoint: APIEndPoint.getMissionComplete, method: .post, parameters: parameters) { (result: Result<MissionStatusData, Error>) in
            switch result {
            case .success(let decodedData):
                completion(decodedData)
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    func getMissionReward(_ missionID: String, completion:@escaping(ResponseData?) -> Void) {
        
        var parameters = HttpsParameters().getTimeStampAndDeviceWithoutLang()
        parameters[K.missionID] = missionID
        
        logParameters(functionName: #function, parameters: parameters)
        
        NetworkManager.shared.request(endpoint: APIEndPoint.getMisionReward, method: .post, parameters: parameters) { (result: Result< ResponseData, Error>) in
            switch result {
            case .success(let decodedData):
                completion(decodedData)
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    
    func getFloor(buildingID: Int, completion: @escaping(GetFloorData?) -> Void) {
        
        var parameters = ["ab_id" : "\(buildingID)"]
        
        NetworkManager.shared.request(endpoint: APIEndPoint.getFloor , method: .get, parameters: parameters) { (result: Result< GetFloorData, Error>)  in
            switch result {
            case .success(let decodedData):
                completion(decodedData)
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
 
    
    
    private func logParameters(functionName: String, parameters: [String: Any]) {
        print(functionName, "-Parameters: \(parameters)")
    }
}
