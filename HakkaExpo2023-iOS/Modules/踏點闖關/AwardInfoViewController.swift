//
//  AwardInfo.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/12.
//

import UIKit

class AwardInfoViewController: BasicViewController {
    
    @IBOutlet weak var missionDataLabel: UILabel!
    @IBOutlet weak var dailyRedeemTimeLabel: UILabel!
    @IBOutlet weak var awardInfoTextView: UITextView!
    @IBOutlet weak var awardImageView: UIImageView!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var noticeTitleLabel: UILabel!
    @IBOutlet weak var noticeContainerView: UIView!
    @IBOutlet weak var noticeImageView: UIImageView!
    @IBOutlet weak var receiveAwardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    
    
    private func setupUI() {
        awardImageView.layer.cornerRadius = 12
        receiveAwardButton.layer.cornerRadius = 12
        noticeContainerView.layer.cornerRadius = 12
        noticeContainerView.dropShadow(color: .darkGray, opacity: 0.5, offset: CGSize(width: 0, height: 1), radius: 5)
    }
    
    
    @IBAction func receiveAwardButtinClicked(_ sender: UIButton) {
        
    }
}
