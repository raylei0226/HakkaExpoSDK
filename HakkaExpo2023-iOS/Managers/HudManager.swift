//
//  ProgressHUDManager.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/26.
//


import JGProgressHUD

class HudManager {
    static let shared = HudManager()
    
    private let progressHUD: JGProgressHUD
    
    private init() {
        progressHUD = JGProgressHUD(style: .dark)
        progressHUD.interactionType = .blockAllTouches
        progressHUD.textLabel.font = UIFont.systemFont(ofSize: 16.0)
        progressHUD.hudView.backgroundColor = Configs.Colors.themePurple
        progressHUD.square = true
    }
    
    func showProgress() {
        progressHUD.textLabel.text = K.processing
        progressHUD.show(in: UIApplication.shared.keyWindow!)
    }
    
    func showInfo(withMessage message: String) {
        progressHUD.indicatorView = JGProgressHUDSuccessIndicatorView()
        progressHUD.textLabel.text = message
        progressHUD.show(in: UIApplication.shared.keyWindow!)
        progressHUD.dismiss(afterDelay: 2.0)
    }
    
    func showSuccess(withMessage message: String) {
        progressHUD.indicatorView = JGProgressHUDSuccessIndicatorView()
        progressHUD.textLabel.text = message
        progressHUD.show(in: UIApplication.shared.keyWindow!)
        progressHUD.dismiss(afterDelay: 2.0)
    }
    
    func showError(withMessage message: String) {
        progressHUD.indicatorView = JGProgressHUDErrorIndicatorView()
        progressHUD.textLabel.text = message
        progressHUD.show(in: UIApplication.shared.keyWindow!)
        progressHUD.dismiss(afterDelay: 2.0)
    }
    
    func showProgressWithMessage(_ message: String, seconds: TimeInterval?) {
        progressHUD.textLabel.text = message
        progressHUD.show(in: UIApplication.shared.keyWindow!)
        progressHUD.dismiss(afterDelay: seconds ?? 0.0)
    }
    
    func hide() {
        progressHUD.dismiss()
    }
}
