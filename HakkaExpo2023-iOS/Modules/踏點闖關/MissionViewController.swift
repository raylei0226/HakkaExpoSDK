//
//  MissionViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/8.
//

import UIKit

class MissionViewController: BasicViewController {
    
    private var selectedIndexPath: IndexPath?
    private let awardTicketTableViewCell = Configs.CellNames.awardTicketTableViewCell
    private let missionTableViewCell = Configs.CellNames.missionTableViewCell
    private var segmentIndex: Int = 0
    
    var awardTicketViewModel = AwardTicketViewModel()
    var missionViewModel = MissionViewModel()
    var missionApiType: MissionApiType!
    
    
    @IBOutlet weak var missionSegment: CustomSegmentedControl!
    @IBOutlet weak var awardContainerView: UIView!
    @IBOutlet weak var missionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "踏點闖關"
        setupSegment()
        
        //註冊cell
        missionTableView.register(UINib(nibName: "AwardTicketTableViewCell", bundle: Bundle(for: MissionViewController.self)), forCellReuseIdentifier: awardTicketTableViewCell)
        awardTicketViewModel.observers.append(self)
        missionTableView.register(UINib(nibName: "MissionTableViewCell", bundle: Bundle(for: MissionViewController.self)), forCellReuseIdentifier: missionTableViewCell)
        missionViewModel.observers.append(self)
    }
    
    private func setupSegment() {
        let buttonTitles = ["任務", "獎勵"]
        let imageNames = ["badge", "badgeGray", "gift", "giftGray"]
        var buttonImages: [UIImage] = []
        
        let bundle = Bundle(for: MissionViewController.self)
        for imageName in imageNames {
            if let image = UIImage(named: imageName, in: bundle, compatibleWith: nil) {
                buttonImages.append(image)
            }
        }
        
        missionSegment.delegate = self
        missionSegment.setButtons(buttonTitles: buttonTitles, buttonImages: buttonImages)
        awardContainerView.isHidden = true
    }
    
    
    private func configDataOfIndex(index: Int) {
        segmentIndex = index
        awardContainerView.isHidden = (index == 0 ? true : false)
        self.view.bringSubviewToFront(awardContainerView)
    }
    
    private func showZeroAwardTicketView() {
        
    }
}

extension MissionViewController: CustomSegmentedControlDelegate {
    func changeToIndex(index: Int) {
        self.configDataOfIndex(index: index)
    }
}


extension MissionViewController: AwardTicketViewModelObserver, MissionViewModelObserver {
    
    func awardTicketUpdated(_ tickets: [String]) {
        print("Tickets:\(tickets)")
    }
    
    func missionItemsUpdated(_ missions: [String]) {
        print("Missions:\(missions)")
        DispatchQueue.main.async {
            self.missionTableView.reloadData()
        }
    }
}


extension MissionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (segmentIndex == 0) ? missionViewModel.numberOfItems : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentIndex == 0 {
            guard let missionCell = tableView.dequeueReusableCell(withIdentifier: missionTableViewCell, for: indexPath) as? MissionTableViewCell else { return UITableViewCell() }
            
            let missionCellInfoData = missionViewModel.getItems(at: indexPath.item)
            
            missionCell.cofigure(title: missionCellInfoData.0, endTime: missionCellInfoData.1, imgURL: missionCellInfoData.2)
            
            return missionCell
        }
        
        return UITableViewCell()
    }
}
