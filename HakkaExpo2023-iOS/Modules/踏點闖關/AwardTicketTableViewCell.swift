//
//  awardTicketTableViewCell.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/12.
//

import UIKit

class AwardTicketTableViewCell: UITableViewCell {

    @IBOutlet weak var awardTicketImageView: UIImageView!
    @IBOutlet weak var giftImageView: UIImageView!
    @IBOutlet weak var awardTitleLabel: UILabel!
    @IBOutlet weak var deadLineLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
