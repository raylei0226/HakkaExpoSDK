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

enum ARMenuType {
    case arInteraction, arNavigation
}

enum Asset: String {
    case back = "back"
    case userLocation = "user_location"
    case poiBackground = "poi_background"
    
    var image: UIImage? {return UIImage(named: rawValue, in: Configs.Bunlde(), compatibleWith: nil)
    }
}

enum MLAlertViewType {
    case arrival
    case notYeyArrived
    case correctAnswer
    case receivedTheReward
}

enum MissionApiType: String {
    case mission = "mission"
    case reward = "reward"
}

struct Configs {
    
    
    struct BoundleID{
        static let id = "omniguider.HakkaExpo2023-iOS.com"
    }
    
    static var Bunlde = {
        Bundle(identifier: BoundleID.id)
    }
    
    static var encryptToken = "hakkaapp://"
    
    //專案配色
    struct Colors {
        
        static let themePurple = #colorLiteral(red: 0.4517806172, green: 0.1928339303, blue: 0.5554947853, alpha: 1)
        static let buttonOrange = #colorLiteral(red: 0.9343007803, green: 0.4688757658, blue: 0.210223943, alpha: 1)
        static let notEnabledGray = #colorLiteral(red: 0.8666666746, green: 0.8666666746, blue: 0.8666666746, alpha: 1)
        static let lightOrange = #colorLiteral(red: 0.9850116372, green: 0.9355557561, blue: 0.9105494022, alpha: 1)
        static let missionBlue = #colorLiteral(red: 0.1137254902, green: 0.3137254902, blue: 0.6352941176, alpha: 1)
        static let disableViewGray = #colorLiteral(red: 0.9529411765, green: 0.968627451, blue: 0.9882352941, alpha: 1)
        
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
        static let arMenuTableViewCell = "arMenuTableViewCell"
        static let awardTicketTableViewCell = "awardTicketTableViewCell"
        static let missionLevleCollectionViewCell = "missionLevleCollectionViewCell"
        static let missionTableViewCell = "missionTableViewCell"
    }
    
    struct Network {
        static let domain = "https://hakkaexpo-test.omniguider.com"
        static let officialWebsite = "https://www.hakkaexpo2023.tw/"
        static let mapWebsite = "https://www.hakkaexpo2023.tw/facility/fourPlace"
    }
}

struct K {
    static let processing = "處理中"
}
