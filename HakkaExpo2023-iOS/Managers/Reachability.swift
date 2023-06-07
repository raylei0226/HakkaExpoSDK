//
//  Reachability.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/19.
//

import Foundation
import Alamofire

//監聽網路狀態
class Reachability {
    
    static let shared = Reachability()
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.hakkaexpo2023.tw")
    
    func startNetworkReachabilityObserver() {
        
        reachabilityManager?.startListening(onQueue: .main, onUpdatePerforming: { status in
            
            switch status {
            case .notReachable:
                print("The network is not reachable")
            case .unknown:
                print("It is unknown whether the network is reachable")
            case .reachable(let connectionType):
                switch connectionType {
                case .ethernetOrWiFi:
                    print("The network is reachable over the WiFi connection")
                case .cellular:
                    print("The network is reachable over the cellular connection")
                }
            }
        })
    }
}
