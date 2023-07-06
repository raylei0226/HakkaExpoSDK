//
//  DirectionMarkersListModel.swift
//  NAVISDK
//
//  Created by Jelico on 2021/6/5.
//

import Foundation
import GoogleMaps

struct DirectionMarkersListModel {
    var zoom21_markers: [GMSMarker] = []
    var zoom20_markers: [GMSMarker] = []
    var zoom18_markers: [GMSMarker] = []
    var zoom17_markers: [GMSMarker] = []
    var zoom16_markers: [GMSMarker] = []
    var zoom14_markers: [GMSMarker] = []
    
    init(coordinates: [CLLocationCoordinate2D]) {
        var coordinates = coordinates
        zoom21_markers = self.generateDirectionMarkersBy(coordinates: coordinates)
        
        coordinates = self.halfCoordinates(coordinates)
        zoom20_markers = self.generateDirectionMarkersBy(coordinates: coordinates)

        coordinates = self.halfCoordinates(coordinates)
        zoom18_markers = self.generateDirectionMarkersBy(coordinates: coordinates)

        coordinates = self.halfCoordinates(coordinates)
        zoom17_markers = self.generateDirectionMarkersBy(coordinates: coordinates)

        coordinates = self.halfCoordinates(coordinates)
        zoom16_markers = self.generateDirectionMarkersBy(coordinates: coordinates)
        
        coordinates = self.halfCoordinates(coordinates)
        zoom14_markers = self.generateDirectionMarkersBy(coordinates: coordinates)
    }
        
    func getDirectionMarkersBy(zoom: Float) -> [GMSMarker] {
        if zoom >= 20.5 {
            return zoom21_markers
        }else if zoom >= 20 {
            return zoom20_markers
        }else if zoom >= 18 {
            return zoom18_markers
        }else if zoom >= 17 {
            return zoom17_markers
        }else if zoom >= 16 {
            return zoom16_markers
        }else {
            return zoom14_markers
        }
    }
        
    //產生有方向圖示的marker，佈滿路線
    func generateDirectionMarkersBy(coordinates: [CLLocationCoordinate2D]) -> [GMSMarker] {
        guard coordinates.count > 0 else{
            return []
        }
        
        var markers: [GMSMarker] = []

        for i in 0..<coordinates.count - 1 {
            let marker = GMSMarker()
            marker.position = coordinates[i]
            
            let point1 = coordinates[i]
            let point2 = coordinates[i + 1]
            let rotation = NaviUtility.GetBearingBetweenTwoPoints(point1: point1, point2: point2)
            
            marker.rotation = rotation
            marker.icon = UIImage().poiDirectionImage(id: 20000, bundle: Bundle(for: MapVC.self))
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            markers.append(marker)
        }
        
        //最後一個marker用透明icon，為了給前一個marker計算bearing
        let emptyMarker = self.getEmptyLastMarker(lastCoordinate: coordinates.last!)
        markers.append(emptyMarker)

        return markers
    }
    
    func halfCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        guard coordinates.count > 0 else{
            return []
        }

        var newCoordinates: [CLLocationCoordinate2D] = []
        newCoordinates.append(coordinates[0])
        
        for i in 1..<coordinates.count {
            if (i % 2 == 0) || (i == coordinates.count - 1) {
                newCoordinates.append(coordinates[i])
            }
        }
        return newCoordinates
    }
    
    func getEmptyLastMarker(lastCoordinate: CLLocationCoordinate2D) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = lastCoordinate
        marker.icon = UIImage(named: "emptyMarker", in: Bundle(for: MapVC.self), compatibleWith: nil)
        return marker
    }
}
