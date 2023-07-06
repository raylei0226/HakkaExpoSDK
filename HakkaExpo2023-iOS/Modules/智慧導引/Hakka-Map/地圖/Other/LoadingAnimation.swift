//
//  LoadingAnimation.swift
//  TonyTsai
//
//  Created by Jelico on 2017/9/28.
//  Copyright © 2017年  Jolly. All rights reserved.
//

import UIKit

class LoadingAnimation: NSObject {
    static let shared =  LoadingAnimation()

    private var indicatorView: UIActivityIndicatorView!
    private var container: UIView!
    private var textLabel: UILabel!
    private var isLoading = false
    private var window: UIWindow!
    
    override private init() {
        super.init()
        self.create()
    }
    
    func create() {
        guard let window = (UIApplication.shared.keyWindow) else {
            return
        }
        self.window = window
        self.container = UIView()
        self.indicatorView = UIActivityIndicatorView()
        self.container.frame = CGRect(x: 0.0, y: 0.0, width: 80, height: 80)
        self.container.layer.cornerRadius = 8
        self.container.center = window.center
        self.container.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        self.indicatorView.center = CGPoint(x: (self.container.frame.width / 2), y: (self.container.frame.height / 2) - 10)
        self.textLabel = UILabel()
        self.textLabel.frame = CGRect(x: 0, y: 0, width: 70, height: 20)
        self.textLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.textLabel.font = UIFont(name: "Avenir Light", size: 14)
        self.textLabel.textAlignment = .center
        self.textLabel.center = CGPoint(x: self.indicatorView.center.x, y: self.indicatorView.center.y + 30)
        self.indicatorView.hidesWhenStopped = true
        self.indicatorView.style = .whiteLarge
        self.container.addSubview(self.textLabel)
        self.container.addSubview(self.indicatorView)
    }

    func start(title: String) {
        guard
            isViewsExist(),
            !isLoading
        else {
            return
        }
        
        DispatchQueue.main.async {
            self.textLabel.text = title
            self.indicatorView.startAnimating()
            self.window.addSubview(self.container)
            self.isLoading = true
            Timer.scheduledTimer(withTimeInterval: 30, repeats: false, block: {_ in self.stop()
            })
        }
    }
    
    func stop() {
        guard isViewsExist() else {
            return
        }
        
        DispatchQueue.main.async {
            self.container.removeFromSuperview()
            self.isLoading = false
        }
    }
    
    func isViewsExist() -> Bool {
        return (indicatorView != nil && container != nil && textLabel != nil && window != nil)
    }

    func release() {
        guard container != nil else {
            return
        }
        container.removeFromSuperview()
        indicatorView = nil
        container = nil
        textLabel = nil
        isLoading = false
        window = nil
    }
}
