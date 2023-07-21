//
//  Configs.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/19.
//

import Foundation
import UIKit
import CoreBluetooth

enum Keys {
    case wikitude, googleMap
}

enum ARMenuType {
    case arInteraction, arNavigation
}

enum AwardInfoType {
    case levelIntroduction, awardInformation
}

enum Asset: String {
    case back = "back"
    case userLocation = "user_location"
    case poiBackground = "poi_background"
    var image: UIImage? {return UIImage(named: rawValue, in: Configs.Bunlde(), compatibleWith: nil)
    }
}

enum LevelType: String {
    case touchdown = "touchdown"
    case qa = "QA"
}

enum MapDataType {
    case nineGrid(data: NineGrid?)
    case gridInfo(data: GridInfoData?)
}

enum MLAlertViewType {
    case arrival
    case correctAnswer
    case receivedTheReward
    case touchdown
}

enum RwsEnabledStates: String {
    case done = "Done"
    case none = "None"
    case expired = "Expired"
}

enum MissionApiType: String {
    case mission = "mission"
    case reward = "reward"
}

enum ModelFileFormat: String {
    case scn = "scn"
    case glb = "glb"
}


struct Configs {
    
    static var LineBeaconServiceUUID: CBUUID = {
        CBUUID(string: "FE6F")
    }()
    
    struct BoundleID{
        static let id = "omniguider.HakkaExpo2023-iOS.com"
    }
    
    static var Bunlde = {
        Bundle(identifier: BoundleID.id)
    }
    
    static var encryptToken = "hakkaapp://"
    
    static func setupPlaceholderImage(in vcClass: AnyClass) -> UIImage {
        return UIImage(named: "pic2", in: Bundle(for: vcClass), compatibleWith: nil)!
    }

    static let fbKeyForDemo = "AIzaSyDg_0j0HxK-CNlL00Ovx6BVhCIpGzzUXvs"
    
    static let fbKeyForTaoyuanTest = "AIzaSyCz0F623yTaHmLyI_dSOu0fVWVsqFTnHEQ"
    
    static let hakkaTestKey = "AIzaSyCz0F623yTaHmLyI_dSOu0fVWVsqFTnHEQ"
    
    static let fbPlistForDemo = "HakkaGoogleService-Info"
    
    static let fbPlistForTaoyuanTest = "GoogleServiceForTest-Info"
    
    static let hakkaTest = "GoogleService-Info-Test"
    
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
        static let moonJellyfish = "moonJellyfish"
        static let stingray = "stingray"
        static let whaleSwim = "whale_swim"
        static let yellowTang = "yellowTang"
        static let whaleBlue = "whale_blue"
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
        static let anyplaceDomin = "https://omnig-anyplace.omniguider.com/"
    }
    
    struct FireBaseModel {
        var plistName: String
        var apiKey: String
    }
    
    static func configBundelID(with id: String) -> FireBaseModel {
        
        var firebaseModel: FireBaseModel!
        
        if id.contains("demo") {
            firebaseModel = FireBaseModel(plistName: self.fbPlistForDemo, apiKey: self.fbKeyForDemo)
            return firebaseModel
        } else if id.contains("HakkaTest") {
            firebaseModel = FireBaseModel(plistName: self.hakkaTest, apiKey: self.hakkaTestKey)
            return firebaseModel
        } else {
            firebaseModel = FireBaseModel(plistName: self.fbPlistForTaoyuanTest, apiKey: fbKeyForTaoyuanTest)
            return firebaseModel
        }
    }
    
    
    static let kMapStyle = "[" +
      "{" +
      "  \"featureType\": \"administrative.land_parcel\"," +
      "  \"elementType\": \"labels\"," +
      "  \"stylers\": [" +
      "    {" +
      "      \"visibility\": \"off\"" +
      "    }" +
      "  ]" +
      "}," +
      "{" +
      "  \"featureType\": \"poi\"," +
      "  \"elementType\": \"labels.text\"," +
      "  \"stylers\": [" +
      "    {" +
      "      \"visibility\": \"off\"" +
      "    }" +
      "  ]" +
      "}," +
      "{" +
      "  \"featureType\": \"poi.business\"," +
      "  \"stylers\": [" +
      "    {" +
      "      \"visibility\": \"off\"" +
      "    }" +
      "  ]" +
      "}," +
      "{" +
      "  \"featureType\": \"road\"," +
      "  \"elementType\": \"labels.icon\"," +
      "  \"stylers\": [" +
      "    {" +
      "      \"visibility\": \"off\"" +
      "    }" +
      "  ]" +
      "}," +
      "{" +
      "  \"featureType\": \"road.local\"," +
      "  \"elementType\": \"labels\"," +
      "  \"stylers\": [" +
      "    {" +
      "      \"visibility\": \"off\"" +
      "    }" +
      "  ]" +
      "}," +
      "{" +
      "  \"featureType\": \"transit\"," +
      "  \"stylers\": [" +
      "    {" +
      "      \"visibility\": \"off\"" +
      "    }" +
      "  ]" +
      "}" +
    "]"
    
}

struct K {
    static let processing = "處理中"
    static let errorMessage = "處理時發生錯誤，請重新嘗試"
    static let missionID = "m_id"
    static let gridID = "ng_id"
    static let camera = "camera"
    static let fishButton = "fishButton"
    static let googleServicePlist = "googleServicePlist"
    static let googleServiceKey = "googleServiceKey"
}
