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
    @IBOutlet weak var awardStatusLabel: UILabel!
    
    func configure(with data: TicketData) {
                
        let bundle = Bundle(for: MissionViewController.self)
        let url = URL(string: data.mImg!)
        let image = (data.rwsEnabled == RwsEnabledStates.none.rawValue) ? UIImage(named: "awardTicket", in:  bundle, compatibleWith: nil) : UIImage(named: "awardTicket_gray", in:  bundle, compatibleWith: nil)
        
        awardTicketImageView.image = image
        self.isUserInteractionEnabled = (data.rwsEnabled == "Done") ? false : true
        let states = self.checkStates(statesString: data.rwsEnabled!)
        self.awardStatusLabel.text = states
        awardTitleLabel.text = data.rwTitle
        deadLineLabel.text = "領取期限:\(data.rwExpiredStartTime!) ~ \(data.rwExpiredEndTime!)"
        giftImageView.sd_setImage(with: url , placeholderImage: Configs.setupPlaceholderImage(in: MissionViewController.self))
    }
    
    private func checkStates(statesString: String) -> String {
        if statesString == RwsEnabledStates.done.rawValue {
            return "已領取"
        } else if statesString == RwsEnabledStates.expired.rawValue {
            return "已過期"
        } else if statesString == RwsEnabledStates.none.rawValue {
            return "領取獎勵"
        }
        return ""
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
