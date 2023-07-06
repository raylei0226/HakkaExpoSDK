//
//  ProjectModelList.swift
//  NAVISDK
//
//  Created by Dong on 2023/6/27.
//

import Foundation

struct ProjectModelList {
    
    let hakka_world = ProjectModel()
    let hakka_taiwan = ProjectModel()
    
    var ModelList = [ProjectModel]()
    
    init() {
        setupHakkaWorld()
        setupHakkaTaiwan()
        ModelList = [hakka_world, hakka_taiwan]
    }
    
    private func setupHakkaWorld() {
        hakka_world.domainName = "https://hakkaexpo-test.omniguider.com"
        hakka_world.get_floorAPI = "\(hakka_world.domainName)/api/get_floor?ab_id=4"
        hakka_world.get_aac_categoryAPI = "https://omnig-anyplace.omniguider.com/locapi/get_app_category"
        hakka_world.get_navi_route_xyAPI = "https://omnig-anyplace.omniguider.com/locapi/get_navi_route_xy"
        
        hakka_world.id = "0"
        hakka_world.titleName = "世界館"
        hakka_world.defaultPlanIndex = 1
        hakka_world.defaultPlanLocation = CLLocation(latitude: 25.003190435, longitude: 121.20214653)
        hakka_world.defaultUserCoordinate = hakka_world.defaultPlanLocation.coordinate
        hakka_world.defaultEnteredFloorNumber = "1"
        
        hakka_world.regionRadius = "1000"
        hakka_world.defaultBeginPoiId = "881"
        hakka_world.locateZoom = 18.5
        hakka_world.planBoundZoom = 18.5
    }
    
    private func setupHakkaTaiwan() {
        hakka_taiwan.domainName = "https://hakkaexpo-test.omniguider.com"
        hakka_taiwan.get_floorAPI = "\(hakka_taiwan.domainName)/api/get_floor?ab_id=4"
        hakka_taiwan.get_aac_categoryAPI = "https://omnig-anyplace.omniguider.com/locapi/get_app_category"
        hakka_taiwan.get_navi_route_xyAPI = "https://omnig-anyplace.omniguider.com/locapi/get_navi_route_xy"
        
        hakka_taiwan.id = "1"
        hakka_taiwan.titleName = "臺灣館"
        hakka_taiwan.defaultPlanIndex = 1
        hakka_taiwan.defaultPlanLocation = CLLocation(latitude: 25.003190435, longitude: 121.20214653)
        hakka_taiwan.defaultUserCoordinate = hakka_taiwan.defaultPlanLocation.coordinate
        hakka_taiwan.defaultEnteredFloorNumber = "1"
        
        hakka_taiwan.regionRadius = "1000"
        hakka_taiwan.defaultBeginPoiId = "881"
        hakka_taiwan.locateZoom = 18.5
        hakka_taiwan.planBoundZoom = 18.5
    }
}
