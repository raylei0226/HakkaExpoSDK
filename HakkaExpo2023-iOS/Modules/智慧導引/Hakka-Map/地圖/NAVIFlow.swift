//
//  NAVIFlow.swift
//  NAVISDK
//
//  Created by Dong on 2023/6/27.
//

import UIKit
 
class NAVIFlow: NSObject {
    
    private var rootVC: UIViewController?
    
    func start(target vc: UIViewController, id: String) {
        if !LoadingAnimation.shared.isViewsExist() {
            LoadingAnimation.shared.create()
        }
        NaviProject.startService(id)
        rootVC = vc
        checkData()
    }
    
    private func pushToNaviMain() {
        LoadingAnimation.shared.stop()
        let naviMain = UIStoryboard(name: "NaviMain", bundle: Bundle(for: NaviMainVC.self)).instantiateViewController(withIdentifier: "NaviMainVC") as! NaviMainVC
        rootVC?.navigationController?.pushViewController(naviMain, animated: true)
    }

    private func checkData() {
        if NaviUtility.hasDownloadPlanData {
            pushToNaviMain()
        }else {
            LoadingAnimation.shared.start(title: "Loading...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: checkData)
        }
    }
}
