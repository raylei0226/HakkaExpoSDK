//
//  LocationService.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/6.
//

import Foundation
import CoreLocation

import Foundation
import CoreLocation

class LocationService: NSObject {
    static let shared = LocationService()
    static private(set) var location: CLLocation?
    static private(set) var heading: CLLocationDirection?
    
    private var manager = CLLocationManager()
    
    func setup() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        manager.startUpdatingHeading()
        manager.startUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        LocationService.location = location
        NotificationCenter.default.post(name: .didUpdateLocation, object: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else {return}
        if newHeading.trueHeading > 0 {
            LocationService.heading = newHeading.trueHeading
        }else {
            LocationService.heading = newHeading.magneticHeading
        }
        NotificationCenter.default.post(name: .didUpdateHeading, object: nil)
    }
}
