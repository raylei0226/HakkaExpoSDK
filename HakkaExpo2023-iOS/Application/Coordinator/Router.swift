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
}
