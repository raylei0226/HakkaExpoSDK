//
//  AlertManager.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/6.
//

import UIKit

class AlertManager {
    static func showAlert(
        in viewController: UIViewController,
        title: String? = nil,
        message: String? = nil,
        preferredStyle: UIAlertController.Style = .alert,
        actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default, handler: nil)],
        completion: (() -> Void)? = nil
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        actions.forEach { alertController.addAction($0) }
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: completion)
        }
    }
    
    static func topViewController() -> UIViewController? {
           if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
               var topViewController = rootViewController
               while let presentedViewController = topViewController.presentedViewController {
                   topViewController = presentedViewController
               }
               return topViewController
           }
           return nil
       }
}
