//
//  Router.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/30.
//

import UIKit

@objc public class Router: NSObject {
    
    public static let shared = Router()
    
    private var window: UIWindow?
    
    private override init() {}
    
    public func startApp(_ vc: UIViewController) {
        guard let mainVC = UIStoryboard(name: "MainPage", bundle: Configs.Bunlde()).instantiateInitialViewController() else {
            return
        }
        mainVC.modalPresentationStyle = .fullScreen
        vc.present(mainVC, animated: true)
        LocationService.shared.setup()
    }
    
    func navigateToPanorama(_ vc: UIViewController) {
        let panoramaVC = UIStoryboard(name: "Panorama", bundle: Configs.Bunlde()).instantiateViewController(withIdentifier: "PanoramaVC")
        vc.navigationController?.pushViewController(panoramaVC, animated: true)
    }
    
    func navigateToArMenu(_ vc: UIViewController, _ type: ARMenuType) {
        let arMenuVC = UIStoryboard(name: "ARMenu", bundle: Configs.Bunlde()).instantiateViewController(withIdentifier: "ARMenuVC") as! ARMenuViewController
        arMenuVC.type = type
        vc.navigationController?.pushViewController(arMenuVC, animated: true)
    }
    
    func navigateToSkyLantern(_ vc: UIViewController) {
        let skyLanternVC = UIStoryboard(name: "SkyLantern", bundle: Configs.Bunlde()).instantiateViewController(withIdentifier: "SkyLanternVC")
        vc.navigationController?.pushViewController(skyLanternVC, animated: true)
    }
    
    func navigationToMission(_ vc: UIViewController) {
        let missionVC = UIStoryboard(name: "Mission", bundle: Configs.Bunlde()).instantiateViewController(withIdentifier: "MissionVC")
        vc.navigationController?.pushViewController(missionVC, animated: true)
    }
    
    func navigationToAwardInfo(_ vc: UIViewController) {
        let awardInfoVC = UIStoryboard(name: "Mission", bundle: Configs.Bunlde()).instantiateViewController(withIdentifier:  "AwardInfoVC")
        vc.navigationController?.pushViewController(awardInfoVC, animated: true)
    }
    
    func navigationToMissionLevel(_ vc: UIViewController, itemData: MissionInfoData?) {
        let missionLevleVC = UIStoryboard(name: "Mission", bundle: Configs.Bunlde()).instantiateViewController(withIdentifier: "MissionLevelVC") as! MissionLevelViewController
        missionLevleVC.missoinInfoData = itemData
        vc.navigationController?.pushViewController(missionLevleVC, animated: true)
        
    }
    
    func navigationToAwardInfo(_ vc: UIViewController, infoType: AwardInfoType, gridData: NineGrid?, ticketData: TicketData?) {
        
        let awardInfoVC = UIStoryboard(name: "Mission", bundle: Configs.Bunlde()).instantiateViewController(withIdentifier: "AwardInfoVC") as! AwardInfoViewController
        
        switch infoType {
        case .levelIntroduction:
            awardInfoVC.awardInfoType = infoType
            awardInfoVC.gridData = gridData
            
        case .awardInformation:
            awardInfoVC.awardInfoType = infoType
            awardInfoVC.ticketData = ticketData
        }
        vc.navigationController?.pushViewController(awardInfoVC, animated: true)
    }
    
    func navigationToQusetion(_ vc: UIViewController) {
        let questionVC = UIStoryboard(name: "Mission", bundle: Configs.Bunlde()).instantiateViewController(withIdentifier: "QuestionVC") as! QuestionViewControler
        vc.navigationController?.pushViewController(questionVC, animated: true)
        
    }
    
    func navigationToaAuarium(_ vc: UIViewController) {
        let aquariumVC = UIStoryboard(name: "Aquarium", bundle: Configs.Bunlde()).instantiateViewController(withIdentifier: "aquariumVC")
        as! AquariumViewController
        vc.navigationController?.pushViewController(aquariumVC, animated: true)
    }
    
    func navigationToMissionMap(_ vc: UIViewController, gridInfoData: GridInfoData) {
        let missionMapVC = UIStoryboard(name: "Mission", bundle: Configs.Bunlde()).instantiateViewController(withIdentifier: "MissionMapVC") as! MissionMapViewController
        missionMapVC.gridInfoData = gridInfoData
        vc.navigationController?.pushViewController(missionMapVC, animated: true)
    }
}
