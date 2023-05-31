//
//  ViewController.swift
//  Demo
//
//  Created by 雷承宇 on 2023/5/19.
//

import UIKit
import HakkaExpo2023_iOS

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    @IBAction func demoButtonClicked(_ sender: Any) {
        
        Router.shared.startApp(self)
    }
}

