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
    
    private var panoramaViewModel = PanoramaViewModle()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "360環景"
        
        panoramaTableView.register(UINib(nibName: "PanoramaTableViewCell", bundle: Bundle(for: PanoramaViewController.self)), forCellReuseIdentifier: Configs.CellNames.panoramaTableViewCell)
        
        panoramaViewModel.observers.append(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func showWebView(_ url: String) {
        let webVC = CommonWebViewController(url: URL(string: url)!)
        
        self.navigationController?.show(webVC, sender: nil)
    }
}

extension PanoramaViewController: PanoramaViewModelObserver {
    
    func panoramaItemsUpdate(_ items: [String]) {
        print("items:\(items)")
        DispatchQueue.main.async {
            self.panoramaTableView.reloadData()
        }
    }
    
    
}



extension PanoramaViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return panoramaViewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Configs.CellNames.panoramaTableViewCell, for: indexPath) as? PanoramaTableViewCell
        else { return UITableViewCell() }
        
        let cellInfoData = panoramaViewModel.getItems(at: indexPath.item)
        
        cell.cofigure(url: cellInfoData.0, name: cellInfoData.1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let urlData = panoramaViewModel.itemsData else { return }
        
        self.showWebView((urlData.data?[indexPath.row].url!)!)
    }
}
