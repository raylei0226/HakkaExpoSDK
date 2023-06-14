//
//  PanoramaTableViewCell.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/30.
//

import UIKit
import SDWebImage

class PanoramaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellStackView: UIStackView! {
        didSet {
            cellStackView.layer.cornerRadius = 15
            cellStackView.addShadow(color: .lightGray, opacity: 0.5, offset: CGSize(width: 0, height: 1), radius: 12)
        }
    }
    
    @IBOutlet weak var panoramaImageView: UIImageView! {
        didSet {
            panoramaImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            panoramaImageView.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var nameBackgroundView: UIView! {
        didSet {
            nameBackgroundView.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            nameBackgroundView.layer.cornerRadius = 15
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func cofigure(url imageURL: String, name: String) {
//        let url = URL(string: Configs.Network.domain + "/" + imageURL)
        let url = URL(string: imageURL)
        panoramaImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "pic1", in:  Bundle(for: MainPageViewController.self), compatibleWith: nil))
        nameLabel.text = name
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
