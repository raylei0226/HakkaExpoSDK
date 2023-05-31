//
//  PanoramaViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/23.
//

import Foundation
import UIKit

class PanoramaViewController: BasicViewController {
    
    @IBOutlet weak var panoramaTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "360環景"
        
        
        panoramaTableView.register(UINib(nibName: "PanoramaTableViewCell", bundle: Bundle(for: PanoramaViewController.self)), forCellReuseIdentifier: Configs.CellNames.panoramaTableViewCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}

extension PanoramaViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Configs.CellNames.panoramaTableViewCell, for: indexPath) as? PanoramaTableViewCell
        else { return UITableViewCell() }
        
        return cell
    }
}
