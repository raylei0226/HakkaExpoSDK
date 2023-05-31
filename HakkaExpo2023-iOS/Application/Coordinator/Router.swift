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
        guard let mainVC = UIStoryboard(name: "MainPage", bundle: Bundle(identifier: Configs.BoundleID.id)).instantiateInitialViewController() else {
            hud.showError(withStatus: "SDK初始化錯誤")
            hud.dismiss(withDelay: 1.0)
            return
        }
        mainVC.modalPresentationStyle = .fullScreen
        vc.present(mainVC, animated: true)
    }
        
//    func navigateToPanorama(_ vc: UIViewController) {
//        guard let panoramaVC = UIStoryboard(name: "Panorama", bundle: Bundle(identifier: Configs.BoundleID.id)).instantiateInitialViewController() else {
//            hud.showError(withStatus: "環景功能初始化錯誤")
//            hud.dismiss(withDelay: 1.0)
//            return
//        }
//        vc.navigationController?.show(panoramaVC, sender: nil)
//    }
    
    func navigateToPanorama(_ vc: UIViewController) {
        
        let storyBoard = UIStoryboard(name: "Panorama", bundle: Configs.Bunlde() )
        let panoramaVC = storyBoard.instantiateViewController(withIdentifier: "PanoramaVC")
        vc.navigationController?.show(panoramaVC, sender: nil)
    }
}
