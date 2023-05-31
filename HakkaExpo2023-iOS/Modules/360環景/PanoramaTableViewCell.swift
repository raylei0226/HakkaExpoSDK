//
//  PanoramaTableViewCell.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/30.
//

import UIKit

class PanoramaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellStackView: UIStackView! {
        didSet {
            cellStackView.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var panoramaImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
