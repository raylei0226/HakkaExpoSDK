//
//  DebugTrackingView.swift
//  OmniArTaipei
//
//  Created by Dong on 2022/12/16.
//

import UIKit
import ARCoreGeospatial

class DebugTrackingView: UIView {
    
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var horizontalAccuracyLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var verticalAccuracyLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var headingAccuracyLabel: UILabel!
    
    func update(_ geospatial: GARGeospatialTransform) {
        var heading = geospatial.heading
        if heading > 180 {
            heading -= 360
        }
        let latStr = String(format: "%.6f", geospatial.coordinate.latitude)
        let lngStr = String(format: "%.6f", geospatial.coordinate.longitude)
        let hAccuracyStr = String(format: "%.2f", geospatial.horizontalAccuracy)
        let altitudeStr = String(format: "%.2f", geospatial.altitude)
        let vAccuracyStr = String(format: "%.2f", geospatial.verticalAccuracy)
        let headingStr = String(format: "%.1f", geospatial.heading)
        let headingAccuracyStr = String(format: "%.1f", geospatial.headingAccuracy)
        
        coordinateLabel.text = "\(latStr), \(lngStr)"
        horizontalAccuracyLabel.text = "\(hAccuracyStr)m"
        altitudeLabel.text = "\(altitudeStr)m"
        verticalAccuracyLabel.text = "\(vAccuracyStr)m"
        headingLabel.text = "\(headingStr)°"
        headingAccuracyLabel.text = "\(headingAccuracyStr)°"
        
        if geospatial.horizontalAccuracy < 1 {
            coordinateLabel.textColor = .green
            horizontalAccuracyLabel.textColor = .green
        }else if geospatial.horizontalAccuracy < 10 {
            coordinateLabel.textColor = .yellow
            horizontalAccuracyLabel.textColor = .yellow
        }else {
            coordinateLabel.textColor = .red
            horizontalAccuracyLabel.textColor = .red
        }
        if geospatial.verticalAccuracy < 5 {
            altitudeLabel.textColor = .green
            verticalAccuracyLabel.textColor = .green
        }else if geospatial.verticalAccuracy < 10 {
            altitudeLabel.textColor = .yellow
            verticalAccuracyLabel.textColor = .yellow
        }else {
            altitudeLabel.textColor = .red
            verticalAccuracyLabel.textColor = .red
        }
    }
}
