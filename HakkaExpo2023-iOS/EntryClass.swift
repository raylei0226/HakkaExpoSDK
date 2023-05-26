//
//  EntryClass.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/26.
//

import UIKit

@objc public class EntryClass: NSObject {
    
    public static let shared = EntryClass()
    
    public func start(_ vc: UIViewController) {
        
        guard let mainVC = UIStoryboard(name: "MainPage", bundle: Bundle(identifier: Configs.BoundleID.id)).instantiateInitialViewController() else {
            hud.showError(withStatus: "SDK初始化錯誤")
            hud.dismiss(withDelay: 1.0)
            return
        }
        
        mainVC.modalPresentationStyle = .fullScreen
        
        vc.present(mainVC, animated: true)
    }
}


