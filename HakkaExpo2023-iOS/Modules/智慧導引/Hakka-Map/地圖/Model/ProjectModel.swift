//
//  ProjectModel.swift
//  NAVISDK
//
//  Created by Jelico on 2021/5/28.
//

import Foundation
import CoreLocation

class ProjectModel {
    var id: String = ""
    var titleName = ""
    var domainName = ""
    var defaultUserCoordinate: CLLocationCoordinate2D!
    var defaultPlanIndex: Int!
    var defaultPlanLocation: CLLocation!
    var defaultEnteredFloorNumber = ""
    var regionRadius: String = ""
    var defaultBeginPoiId = ""
    var get_floorAPI = ""
    var get_navi_nearby_typeAPI = ""
    var get_keywordAPI = ""
    var get_theme_guideAPI = ""
    var get_aac_categoryAPI = ""
    var ac_categoryAPI = ""
    var get_navi_route_xyAPI = ""
    var get_navi_routeAPI = ""

    // friends group
    var send_user_locationAPI  = ""
    var join_groupAPI  = ""
    var add_groupAPI  = ""
    var update_groupAPI  = ""
    var leave_groupAPI  = ""
    var testPlanId = ""

    var locateZoom: Float!
    var planBoundZoom: Float!
}
