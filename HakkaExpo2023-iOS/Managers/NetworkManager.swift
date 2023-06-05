//
//  NewworkManager.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/22.
//

import Foundation
import Alamofire


//class NetworkManager {
//    static let shared = NetworkManager()
//
//    private init() {}
//
//    func request(endpoint: APIEndPoint,
//                 method: HTTPMethod,
//                 parameters: Parameters? = nil,
////                 encoding: ParameterEncoding? = nil,
//                 headers: HTTPHeaders? = nil,
//                 completion: @escaping (Result<Data, Error>) -> Void) {
//
//        guard let url = endpoint.url else {
//            let error = NSError(domain: "InvalidURL", code: -1, userInfo: nil)
//            completion(.failure(error))
//            return
//        }
//
//        AF.request(url,
//                   method: method,
//                   parameters: parameters,
////                   encoding: encoding,
//                   headers: headers)
//        .responseData { response in
//            switch response.result {
//            case .success(let data):
//                completion(.success(data))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//
//    }
//}


class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func request<T: Decodable>(endpoint: APIEndPoint,
                               method: HTTPMethod,
                               parameters: Parameters? = nil,
//                               encoding: ParameterEncoding? = nil,
                               headers: HTTPHeaders? = nil,
                               completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = endpoint.url else {
            let error = NSError(domain: "InvalidURL", code: -1, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        AF.request(url,
                   method: method,
                   parameters: parameters,
//                   encoding: encoding,
                   headers: headers)
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let decodedData):
                completion(.success(decodedData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
