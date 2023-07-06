//
//  ProjectData.swift
//  NAVISDK
//
//  Created by Jelico on 2021/3/26.
//

import Foundation
import UIKit

@objc class NaviProject: NSObject {
    static var id: String!
    static var color: UIColor!
    static var usedProjectModel: ProjectModel!
    static var beginPoiId: String {
        return self.usedProjectModel.defaultBeginPoiId
    }
    static var planModels: [PlanModel] = []
    static var aacCategoryModels: [AacCategoryModel] = []
    static var presentedPoiModels: [OGPointModel] = []
    static var isTaipeiProject = false

    @objc static func startService(_ projectId: String) {
        NaviProject.id = projectId
        NaviProject.color = UIColor(named: "hakkaColor", in: Configs.Bunlde(), compatibleWith: nil)!
        
        self.setProjectModelBy(projectId, completion: {result in
            guard result else {
                fatalError("ID無效")
            }
            
            self.getPlanData()
            LocationBase.shared.start()
        })
    }
    
    private static func setProjectModelBy(_ projectId: String, completion: @escaping ((_ result: Bool) -> Void) ) {
        guard let projectModel = NaviUtility.GetProjectModel(projectId: projectId) else {
            completion(false)
            return
        }
        
        NaviProject.usedProjectModel = projectModel
        completion(true)
    }
    
    private static func getPlanData() {
        NaviUtility.onPlanDownloaded = {data in
            NaviProject.planModels = data
        }
        
        NaviUtility.onAacCategoryDownloaded = {data in
            NaviProject.aacCategoryModels = data
        }
        
        NaviUtility.GetPlanData()
    }
}
