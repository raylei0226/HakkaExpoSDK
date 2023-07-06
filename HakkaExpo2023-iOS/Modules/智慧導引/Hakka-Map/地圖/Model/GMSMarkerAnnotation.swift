//
//  GMSMarkerAnnotation.swift

import MapKit

class GMSMarkerAnnotation: MKPointAnnotation {
    var poiId: Int?
    var name: String?
    var webUrl: String?
    var imageUrl: String?
    var isSelectedMarker = false
    var ac_id: Int?
}
