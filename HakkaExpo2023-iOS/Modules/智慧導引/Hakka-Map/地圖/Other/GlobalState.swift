//
//  FetchData.swift
//  NLPI
//
//  Created by Jelico on 2020/2/4.
//  Copyright © 2020  Jolly. All rights reserved.
//

import Foundation
import CoreLocation

class GlobalState {
    static var tappedCoordinate: CLLocationCoordinate2D?
    static var tappedPlanId: String?
    static var tappedFloorNumber = "1"
    static var nearbyType: NearbyType!
    static var nearbyName: String!
    static var markerMode: MarkerMode! = .Default
    static var selectedDeviceId = ""
    static var beginName = ""
    static var endPoi: OGPointModel!
}
