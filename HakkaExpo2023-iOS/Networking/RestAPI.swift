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
    
    
    func getTopBanner() {
        
        var viewModel = MainPageViewModel()
        
        let parameters = HttpsParameters().getTimeStamp()
        
        print("Parameters: \(parameters)")
        
        NetworkManager.shared.request(endpoint: APIEndPoint.getTopBanner, method: .post, parameters: parameters) { (result: Result<BannerData, Error>) in
            
            switch result {
            case .success(let decodedData):
                viewModel.itemsData = decodedData
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
