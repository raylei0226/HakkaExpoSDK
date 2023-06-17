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
    
    var nineGridData: NineGrid?

    private let spacing: CGFloat = 10.0
    private let cellIdentifier = Configs.CellNames.missionLevleCollectionViewCell
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let data = missoinInfoData else { return }
        self.setupTitleView(with: data)
        missionLevelViewModel = MissionLevelViewModel(missionID: data.mID!)
        missionLevelViewModel?.observers.append(self)
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
        self.missionImageView.sd_setImage(with: URL(string: (data.mImg ?? "")), placeholderImage: UIImage(named: "pic1", in:  Bundle(for: MissionLevelViewController.self), compatibleWith: nil))
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
}

extension MissionLevelViewController: MissionLevelViewModelObserver {
    
    func missionLevelItemsUpdated(_ levelItems: [String], _ isFinshed: Bool) {
        DispatchQueue.main.async {
            self.missionLevelCollectionView.reloadData()
            self.confirmButton.backgroundColor = isFinshed ? Configs.Colors.buttonOrange : UIColor.lightGray
        }
    }
}

extension MissionLevelViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return missionLevelViewModel?.numberOfItems ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MissionLevleCollectionViewCell
        
        guard let nineGridData = missionLevelViewModel?.getModel(at: indexPath.item) else { return UICollectionViewCell() }
        
        self.nineGridData = nineGridData
            
        cell.configure(with: self.nineGridData!)
            
        return cell 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nineGrid = missionLevelViewModel?.getModel(at: indexPath.item) else { return }
        Router.shared.navigationToAwardInfo(self, infoType: .levelIntroduction, gridData: nineGrid, ticketData: nil)
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
        return 5 //左右 中间间隙
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5 //上下 中间间隙
    }
}
