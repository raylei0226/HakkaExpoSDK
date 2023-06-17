//
//  CommonWebViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/1.
//

import UIKit
import WebKit

class CommonWebViewController: UIViewController {
    
    private var webView: WKWebView!
    
    private var url: URL
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "2023世界客家博覽會"
        setupNavigationBar()
        setupWebView()
        loadURL()
    }
    
    private func setupWebView() {
        let webViewConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: webViewConfiguration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
    }
    
    private func loadURL() {
        let request = URLRequest(url: url)
        webView.load(request)
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

        }
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        
    }
}
