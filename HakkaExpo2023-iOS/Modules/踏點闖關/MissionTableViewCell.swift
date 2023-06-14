//
//  MissionTableViewCell.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/14.
//

import UIKit
import SDWebImage

class MissionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var missionCellStackView: UIStackView! {
        didSet {
            missionCellStackView.layer.cornerRadius = 15
            missionCellStackView.addShadow(color: .lightGray, opacity: 0.5, offset: CGSize(width: 0, height: 1), radius: 12)
        }
    }
    
    @IBOutlet weak var missionImageView: UIImageView! {
        didSet{
            missionImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            missionImageView.layer.cornerRadius = 15
        }
    }
    
    @IBOutlet weak var bottomView: UIView! {
        didSet {
            bottomView.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            bottomView.layer.cornerRadius = 15
    }
}
    
    @IBOutlet weak var missionTitlerLabel: UILabel!
    @IBOutlet weak var missionEndTimeLabel: UILabel!
    
    
    func cofigure(title: String, endTime: String, imgURL: String ) {
        let url = URL(string: imgURL)
        missionImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "pic2", in:  Bundle(for: MainPageViewController.self), compatibleWith: nil))
        missionTitlerLabel.text = title
        missionEndTimeLabel.text = endTime
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
