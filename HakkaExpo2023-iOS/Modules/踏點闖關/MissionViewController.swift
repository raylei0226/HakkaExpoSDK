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
    private var segmentIndex: Int!
    
    var awardTicketViewModel = AwardTicketViewModel()
    var missionViewModel = MissionViewModel()

    @IBOutlet weak var missionSegment: CustomSegmentedControl!
    @IBOutlet weak var awardContainerView: UIView!
    @IBOutlet weak var missionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "踏點闖關"
        setupSegment()
        
        //註冊cell
        missionTableView.register(UINib(nibName: "AwardTicketTableViewCell", bundle: Bundle(for: MissionViewController.self)), forCellReuseIdentifier: awardTicketTableViewCell)
       
        missionTableView.register(UINib(nibName: "MissionTableViewCell", bundle: Bundle(for: MissionViewController.self)), forCellReuseIdentifier: missionTableViewCell)
        missionViewModel.observers.append(self)
        awardTicketViewModel.observers.append(self)
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
        self.missionSegment.delegate = self
        self.missionSegment.setButtons(buttonTitles: buttonTitles, buttonImages: buttonImages)
        self.awardContainerView.isHidden = true
        self.segmentIndex = 0
    }
    
    
    private func configDataOfIndex(index: Int) {
        self.segmentIndex = index
        DispatchQueue.main.async {
            self.missionTableView.reloadData()
        }
    }
    
    private func showZeroAwardTicketView() {
        awardContainerView.isHidden = false
        self.view.bringSubviewToFront(awardContainerView)
    }
}

extension MissionViewController: CustomSegmentedControlDelegate {
    
    func changeToIndex(index: Int) {
        self.configDataOfIndex(index: index)
    }
}

extension MissionViewController: AwardTicketViewModelObserver, MissionViewModelObserver {
    
    func awardTicketUpdated(_ tickets: [String]) {
        if tickets.count > 0 {
            DispatchQueue.main.async {
                self.missionTableView.reloadData()
            }
        }
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
        return (segmentIndex == 0) ? missionViewModel.numberOfItems : awardTicketViewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentIndex == 0 {
            guard let missionCell = tableView.dequeueReusableCell(withIdentifier: missionTableViewCell, for: indexPath) as? MissionTableViewCell else { return UITableViewCell() }
            
            let missionCellInfoData = missionViewModel.getItems(at: indexPath.item)
            
            missionCell.cofigure(title: missionCellInfoData.title, endTime: missionCellInfoData.endTime, imgURL: missionCellInfoData.imgURL)
            
            return missionCell
            
        } else if segmentIndex == 1 {
            
            guard let awardCell = tableView.dequeueReusableCell(withIdentifier: awardTicketTableViewCell, for: indexPath) as? AwardTicketTableViewCell else { return UITableViewCell() }
            
            let ticketData = awardTicketViewModel.getItem(at: indexPath.item)
            
            awardCell.configure(with: ticketData)
            
            return awardCell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segmentIndex == 0 {
            
            let infoData = missionViewModel.getModel(at: indexPath.item)
            Router.shared.navigationToMissionLevel(self, itemData: infoData)
        } else {
            let ticketData = awardTicketViewModel.getItem(at: indexPath.item)
            Router.shared.navigationToAwardInfo(self, infoType: .awardInformation, gridData: nil, ticketData: ticketData)
        }
    }
}
