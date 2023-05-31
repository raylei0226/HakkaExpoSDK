//
//  Configs.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/19.
//

import Foundation
import UIKit

enum Keys {
    case wikitude, googleMap
}


struct Configs {
    
    struct UserDefaultsKeys {
        static let deviceUUID = "DeviceUUID"
    }
    
    struct BoundleID{
        static let id = "omniguider.HakkaExpo2023-iOS.com"
    }
    
    static var Bunlde = {
        Bundle(identifier: BoundleID.id)
    }
    
    //專案配色
    struct Colors {
        
        static let themePurple = #colorLiteral(red: 0.4517806172, green: 0.1928339303, blue: 0.5554947853, alpha: 1)
        static let buttonOrange = #colorLiteral(red: 0.9343007803, green: 0.4688757658, blue: 0.210223943, alpha: 1)
        static let notEnabledGray = #colorLiteral(red: 0.8666666746, green: 0.8666666746, blue: 0.8666666746, alpha: 1)
        static let lightOrange = #colorLiteral(red: 0.9850116372, green: 0.9355557561, blue: 0.9105494022, alpha: 1)
        
    }
    
    //3DModel名稱
    struct ModelNames {
        static let angelfish = "angelfish"
        static let bannerfish = "bannerfish"
        static let bubble = "bubble"
        static let caranx = "carnax"
        static let clownfish = "clownfish"
        static let doubleSaddle = "doubleSaddle"
        static let greenSeaTurtle = "greenSeaTurtle"
        static let mantaRay = "mantaRay"
        static let moonJellyfish = "moonJellyfish"
        static let powBTang = "powBTang"
        static let stingray = "stingray"
        static let whaleBlue = "whale_blue"
        static let whaleSwim = "whale_swim"
        static let yellowTang = "yellowTang"
    }
    
    
    struct Basic {
        static let backgroundImage = "themeBackground"
    }
    
    //cell name
    
    struct CellNames {
        
        static let carouselCollectionViewCell = "carouselCollectionViewCell"
        static let panoramaTableViewCell = "panoramaTableViewCell"
    }
}
