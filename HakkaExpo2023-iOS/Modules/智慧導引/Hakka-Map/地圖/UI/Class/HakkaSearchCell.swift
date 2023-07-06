//
//  HakkaSearchCell.swift
//  NAVISDK
//
//  Created by Dong on 2023/6/28.
//

import UIKit

class HakkaSearchCell: UITableViewCell {
    //MARK: - Variables
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    //MARK: - Functions
    func setup(point: OGPointModel?, title: String?, type: HakkaSearchVC.TableViewType) {
        if type == .history {
            titleLabel.text = title
        }else if type == .result, let point {
            titleLabel.text = point.name
            setupDistance(with: point)
        }else {
            titleLabel.text = nil
        }
        distanceLabel.isHidden = (type == .history)
    }
    
    private func setupDistance(with point: OGPointModel) {
        distanceLabel.text = "---"
        guard
            let userCoordinate = LocationBase.shared.coordinate,
            let poiCoordinate = point.coordinate
        else {
            return
        }
        let distance = userCoordinate.distance(to: poiCoordinate)
        distanceLabel.text = String(format: "%.1f", distance) + "m"
    }
}
