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
        progressHUD.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        progressHUD.textLabel.text = K.processing
        progressHUD.show(in: UIApplication.shared.keyWindow!)
    }
    
    func showProgress(title: String ,with delay: TimeInterval) {
        progressHUD.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        progressHUD.textLabel.text = title
        progressHUD.show(in: UIApplication.shared.keyWindow!)
        progressHUD.dismiss(afterDelay: delay)
    }
    
    func showInfo(withMessage message: String) {
        progressHUD.indicatorView = JGProgressHUDIndicatorView()
        progressHUD.textLabel.text = message
        progressHUD.show(in: UIApplication.shared.keyWindow!)
        progressHUD.dismiss(afterDelay: 3.5)
    }
    
    func showSuccess(withMessage message: String) {
        progressHUD.indicatorView = JGProgressHUDSuccessIndicatorView()
        progressHUD.textLabel.text = message
        progressHUD.show(in: UIApplication.shared.keyWindow!)
        progressHUD.dismiss(afterDelay: 1.5)
    }
    
    func showError(withMessage message: String) {
        progressHUD.indicatorView = JGProgressHUDErrorIndicatorView()
        progressHUD.textLabel.text = message
        progressHUD.show(in: UIApplication.shared.keyWindow!)
        progressHUD.dismiss(afterDelay: 1.5)
    }
    
    func showProgressWithMessage(_ message: String, seconds: TimeInterval?) {
        progressHUD.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        progressHUD.textLabel.text = message
        progressHUD.show(in: UIApplication.shared.keyWindow!)
        progressHUD.dismiss(afterDelay: seconds ?? 0.0)
    }
    
    func showProgressWithMessageAndDelay(_ message: String, seconds: TimeInterval?, completionHandler: (() -> Void)?) {
        progressHUD.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        progressHUD.textLabel.text = message
        progressHUD.show(in: UIApplication.shared.keyWindow!)
        DispatchQueue.main.asyncAfter(deadline: .now() + (seconds ?? 0.0)) {
            self.progressHUD.dismiss()
            completionHandler?()
        }
    }
    
    func hide() {
        progressHUD.dismiss()
    }
}
