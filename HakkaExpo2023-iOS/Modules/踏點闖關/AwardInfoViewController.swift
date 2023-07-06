//
//  AwardInfo.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/12.
//

import UIKit

class AwardInfoViewController: BasicViewController {
    
    private let scannerManager = QRCodeScannerManager()
    
    var awardInfoType: AwardInfoType = .awardInformation
    
    var gridData: NineGrid?
    
    var ticketData: TicketData?
    
    var markerIndex: Int?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var missionDataLabel: UILabel!
    @IBOutlet weak var awardInfoTextView: UITextView!
    @IBOutlet weak var awardImageView: UIImageView!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var noticeTitleLabel: UILabel!
    @IBOutlet weak var levelInfoLabel: UILabel!
    @IBOutlet weak var noticeContainerView: UIView!
    @IBOutlet weak var noticeImageView: UIImageView!
    @IBOutlet weak var receiveAwardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupUI()
        
        scannerManager.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scannerManager.stopScan()
    }
            
    private func setupUI() {
        
        let isAwardInformation = (awardInfoType == .awardInformation)
        let bundle = Bundle(for: AwardInfoViewController.self)
        let warningImage = UIImage(named: "warning", bundle: bundle)
        let lightBallImage = UIImage(named: "lightBall", bundle: bundle)
        
        let buttonTitle = isAwardInformation ? "領取獎勵" : "開始闖關"
        navigationItem.title = isAwardInformation ? "踏點闖關" : "關卡介紹"
        awardInfoTextView.isHidden = !isAwardInformation
        levelInfoLabel.isHidden = isAwardInformation
        noticeTitleLabel.text = isAwardInformation ? "注意事項" : "關卡提示"
        receiveAwardButton.setTitle(buttonTitle, for: .normal)
        awardImageView.layer.cornerRadius = 12
        receiveAwardButton.layer.cornerRadius = 12
        noticeContainerView.layer.cornerRadius = 12
        noticeContainerView.dropShadow(color: .darkGray, opacity: 0.5, offset: CGSize(width: 0, height: 1), radius: 5)
        
        switch awardInfoType {
        case .levelIntroduction:
            guard let gridData = gridData else { return }
            
            titleLabel.text = gridData.title
            awardImageView.sd_setImage(with: URL(string: gridData.image ?? ""), placeholderImage: Configs.setupPlaceholderImage(in: AwardInfoViewController.self))
            levelInfoLabel.text = gridData.description
            noticeImageView.image = isAwardInformation ? warningImage : lightBallImage
            noticeLabel.text = gridData.question?.tip
            
        case .awardInformation:
            guard let ticketData = ticketData else { return }
            
            missionDataLabel.text = "任務期限：\(ticketData.rwExpiredStartTime!) ~ \(ticketData.rwExpiredEndTime!)"
            titleLabel.text = ticketData.mTitle
            awardImageView.sd_setImage(with: URL(string: ticketData.mImg ?? ""), placeholderImage: Configs.setupPlaceholderImage(in: AwardInfoViewController.self))
            noticeLabel.text = ticketData.rwNotice
            awardInfoTextView.text = ticketData.rwDescribe
        }
    }

    
    @IBAction func receiveAwardButtinClicked(_ sender: UIButton) {
        if sender.titleLabel?.text == "領取獎勵" {
            HudManager.shared.showProgressWithMessage("正在啟用相機", seconds: 1.0)
            scannerManager.startScan(in: view)
        } else {
            Router.shared.navigationToMissionMap(self, gridInfoData: nil, gridData: gridData, isFinding: true, markerNumber: self.markerIndex ?? 1)
        }
    }
}

extension AwardInfoViewController: QRCodeScannerDelegate {

    func qrCodeScanned(result: String) {
        print("掃描結果:\(result)")
        let model = MissionAlertViewModel(alertType: .receivedTheReward)
        MissionAlertView.instance.configure(with: model)
        MissionAlertView.instance.showAlert(with: .receivedTheReward)
    }

    func qrCodeScanFailed(error: Error) {
        print("掃瞄失敗:\(error.localizedDescription)")
    }
}
