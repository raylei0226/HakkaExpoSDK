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
        
        print(#function,"-Parameters: \(parameters)")
        
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
        
        print(#function,"-Parameters: \(parameters)")
        
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
    
    func getMission(completion: @escaping(MissionData?) -> Void) {
        
        var parameters = HttpsParameters().getTimeStampAndDevice()
        parameters["type"] = "mission"
        
        print(#function,"-Parameters: \(parameters)")
        
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
}
