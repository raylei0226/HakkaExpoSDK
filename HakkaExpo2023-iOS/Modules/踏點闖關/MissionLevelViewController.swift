//
//  MissionLevelViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/13.
//

import UIKit
import SDWebImage
import Alamofire

class MissionLevelViewController: BasicViewController {
    
    @IBOutlet weak var missionImageView: UIImageView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var missionTitleLabel: UILabel!
    @IBOutlet weak var missionInfoLabel: UILabel!
    @IBOutlet weak var missionLevelCollectionView: UICollectionView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var missionBackgroundView: UIView!
    @IBOutlet weak var missionLevelScrollView: UIScrollView!
    
    var missoinInfoData: MissionInfoData?
    
    var missionLevelViewModel: MissionLevelViewModel?
    
    var awardTicketViewModel: AwardTicketViewModel?
    
    var gridInfoData: GridInfoData?
    
    var nineGridData: NineGrid?
    
    var ticketData: TicketData?

    var numberSequence: [Int] = []
    
    var markerNumber: Int?
    
    lazy var dispatchGroup = DispatchGroup()
    
    private let spacing: CGFloat = 10.0
    private let cellIdentifier = Configs.CellNames.missionLevleCollectionViewCell
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        self.setupCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var missionID = ""
        
        if let data = missoinInfoData {
            missionID = data.mID!
            UserDefaults.standard.set(missionID, forKey: K.missionID)
            self.setupTitleView(with: data)
        } else {
            missionID = UserDefaults.standard.value(forKey: K.missionID) as! String
        }
        
        missionLevelViewModel = MissionLevelViewModel(missionID: missionID)
        missionLevelViewModel?.observers.append(self)
        //        awardTicketViewModel = AwardTicketViewModel()
        //        awardTicketViewModel?.observers.append(self)
    }
    
    private func setupUI() {
        self.mapButton.layer.cornerRadius = mapButton.bounds.width / 2
        self.mapButton.dropShadow()
        self.missionBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.missionBackgroundView.clipsToBounds = true
        self.missionBackgroundView.layer.cornerRadius = 20
        self.confirmButton.layer.cornerRadius = 12
        self.navigationItem.title = "任務關卡"
    }
    
    private func setupTitleView(with data: MissionInfoData) {
        self.missionTitleLabel.text = data.mTitle
        self.missionInfoLabel.text = data.mDescribe
        self.missionImageView.sd_setImage(with: URL(string: (data.mImg ?? "")), placeholderImage: Configs.setupPlaceholderImage(in: MissionLevelViewController.self))
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        missionLevelCollectionView.collectionViewLayout = layout
        missionLevelCollectionView.dataSource = self
        missionLevelCollectionView.delegate = self
        //註冊cell
        missionLevelCollectionView.register(UINib(nibName: "MissionLevleCollectionViewCell", bundle: Bundle(for: MissionLevelViewController.self)), forCellWithReuseIdentifier: cellIdentifier)
    }
    
    @IBAction func mapButtonClicked(_ sender: UIButton) {
        guard let data = missionLevelViewModel?.getGridInfo() else { return }
        Router.shared.navigationToMissionMap(self, gridInfoData: data, gridData: nil, isFinding: false, markerNumber: markerNumber ?? 1)
    }
    
    @IBAction func confirmButtonClicked(_ sender: UIButton) {
        Router.shared.navigationToAwardInfo(self, infoType: .awardInformation, gridData: nil, ticketData: ticketData, numberIndex: nil)
    }
}

extension MissionLevelViewController: AwardTicketViewModelObserver {
    
    func awardTicketUpdated(_ tickets: [String]) {
        guard let mID = UserDefaults.standard.value(forKey: K.missionID) else { return }
        guard let ticketData = awardTicketViewModel?.getItem(with: mID as! String) else { return }
        self.ticketData = ticketData
        if ticketData.rwsEnabled == RwsEnabledStates.done.rawValue {
            confirmButton.setTitle("獎勵已領取", for: .normal)
            confirmButton.backgroundColor = .lightGray
            confirmButton.isEnabled = false
        }
    }
}

extension MissionLevelViewController: MissionLevelViewModelObserver {
    
    func missionLevelItemsUpdated(_ levelItems: [String], _ isFinshed: Bool) {
        self.missionLevelCollectionView.reloadData()
        self.confirmButton.setTitle("領取獎勵", for: .normal)
        self.confirmButton.backgroundColor = isFinshed ? Configs.Colors.buttonOrange : UIColor.lightGray
        self.confirmButton.isEnabled = isFinshed ? true : false
        self.awardTicketViewModel = AwardTicketViewModel()
        self.awardTicketViewModel?.observers.append(self)
    }
}


extension MissionLevelViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return missionLevelViewModel?.numberOfItems ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MissionLevleCollectionViewCell
        
        guard let nineGridData = missionLevelViewModel?.getModel(at: indexPath.item) else { return UICollectionViewCell() }
        
        guard let numberSequence = missionLevelViewModel?.convertSequence() else { return UICollectionViewCell() }
        
        self.numberSequence = numberSequence
        
        self.nineGridData = nineGridData
    
        cell.configure(with: self.nineGridData!, levelNumber: self.numberSequence[indexPath.row])
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nineGrid = missionLevelViewModel?.getModel(at: indexPath.item) else { return }
        self.markerNumber = indexPath.row + 1
        Router.shared.navigationToAwardInfo(self, infoType: .levelIntroduction, gridData: nineGrid, ticketData: nil, numberIndex: markerNumber)
    }
}

extension MissionLevelViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: missionLevelCollectionView.bounds.width / 3.3, height: missionLevelCollectionView.bounds.height / 3.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5 //左右
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5 //上下 
    }
}
