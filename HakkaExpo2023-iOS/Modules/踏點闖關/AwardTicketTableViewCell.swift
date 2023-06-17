//
//  awardTicketTableViewCell.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/12.
//

import UIKit
import SDWebImage

class AwardTicketTableViewCell: UITableViewCell {

    @IBOutlet weak var awardTicketImageView: UIImageView! {
        didSet {
            awardTicketImageView.dropShadow()
        }
    }
    
    @IBOutlet weak var giftImageView: UIImageView! {
        didSet {
            giftImageView.layer.cornerRadius = 12
        }
    }
    @IBOutlet weak var awardTitleLabel: UILabel!
    @IBOutlet weak var deadLineLabel: UILabel!
    
    func configure(with data: TicketData) {
        
        let bundle = Bundle(for: MissionViewController.self)
        let url = URL(string: data.mImg!)
        let image = (data.rwsEnabled == "Done") ? UIImage(named: "awardTicket", in:  bundle, compatibleWith: nil) : UIImage(named: "awardTicket_gray", in:  bundle, compatibleWith: nil)
        awardTicketImageView.image = image
//        self.isUserInteractionEnabled = (data.rwsEnabled == "Done") ? true : false
        awardTitleLabel.text = data.rwTitle
        deadLineLabel.text = "領取期限:\(data.rwExpiredStartTime!) ~ \(data.rwExpiredEndTime!)"
        giftImageView.sd_setImage(with: url , placeholderImage: UIImage(named: "pic2", in:  Bundle(for: MissionViewController.self), compatibleWith: nil))
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
