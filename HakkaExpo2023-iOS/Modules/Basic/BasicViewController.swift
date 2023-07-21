//
//  BasicViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/29.
//

import UIKit
import GoogleMaps

class BasicViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
       configureBackgroundImage()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
    }
    
    
    private func configureBackgroundImage() {
        let image = UIImage(named: Configs.Basic.backgroundImage, in: Bundle(for: BasicViewController.self), compatibleWith: nil)!
        let backgroundImage = UIImageView(image: image)
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = view.bounds
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        
    }
    
    private func setupNavigationBar() {
        
        if #available(iOS 13.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = Configs.Colors.themePurple
            navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = navigationBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            
        } else {
            // Fallback on earlier versions
        }
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
    
    }
}
