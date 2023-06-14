//
//  MissionLevelViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/13.
//

import UIKit

class MissionLevelViewController: BasicViewController {
    
    @IBOutlet weak var missionImageView: UIImageView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var missionTitleLabel: UILabel!
    @IBOutlet weak var missionInfoLabel: UILabel!
    @IBOutlet weak var missionLevelCollectionView: UICollectionView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var missionBackgroundView: UIView!
    @IBOutlet weak var missionLevelScrollView: UIScrollView!
    
    
    private let numberOfItemsPerRow = [1,2,3,4,5,6,7,8,9]
    private let spacing: CGFloat = 10.0
    private let cellIdentifier = Configs.CellNames.missionLevleCollectionViewCell
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        let bottomOffset = CGPoint(x: 0, y: missionLevelScrollView.contentSize.height - missionLevelScrollView.bounds.size.height)
//        missionLevelScrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    private func setupUI() {
        self.mapButton.layer.cornerRadius = mapButton.bounds.width / 2
        self.mapButton.dropShadow()
        self.missionBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.missionBackgroundView.clipsToBounds = true
        self.missionBackgroundView.layer.cornerRadius = 20
        self.confirmButton.layer.cornerRadius = 12
       
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


extension MissionLevelViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsPerRow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MissionLevleCollectionViewCell
        
        cell.configure(with: numberOfItemsPerRow[indexPath.row])
        
        return cell 
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
