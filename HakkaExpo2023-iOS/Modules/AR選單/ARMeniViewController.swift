//
//  ARMeniViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/6.
//

import UIKit

class ARMenuViewController: BasicViewController {
    
    var type: ARMenuType!

    var pavilionImageArray: [UIImage]!
    
    var interactionImageAray: [UIImage]!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = (type == .arInteraction) ? "AR互動" : "智慧導引"
        setupButton()
    }
    
    private func setupButton() {
        let bundle = Bundle(for: ARMenuViewController.self)
        let taiwanPavilion = UIImage(named: "taiwanPavilion", bundle: bundle)!
        let worldPavilion = UIImage(named: "worldPavilion", bundle: bundle)!
        pavilionImageArray = [worldPavilion, taiwanPavilion]
        
        let skyLantern = UIImage(named: "skyLantern", bundle: bundle)!
        let underTheSea = UIImage(named: "underTheSea", bundle: bundle)!
        interactionImageAray = [skyLantern, underTheSea]
    }
}

extension ARMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Configs.CellNames.arMenuTableViewCell, for: indexPath) as? ARMenuTableViewCell else { return UITableViewCell()}
        
        switch type {
        case .arInteraction:
            self.titleLabel.text = "請選擇主體"
            cell.menuImageView.image = interactionImageAray[indexPath.row]
        case .arNavigation:
            self.titleLabel.text = "請選擇場館"
            cell.menuImageView.image = pavilionImageArray[indexPath.row]
        case .none:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch type {
        case .arInteraction:
            if indexPath.row == 0 {
                Router.shared.navigateToSkyLantern(self)
            }
        case .none:
            break
        case .arNavigation:
            print("前往導航:\(indexPath.row)")
        }
    }
    
}
