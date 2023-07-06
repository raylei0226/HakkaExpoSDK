//
//  HakkaSearchVC.swift
//  NAVISDK
//
//  Created by Dong on 2023/6/28.
//

import UIKit

protocol HakkaSearchVCDelegate {
    func hakkaSearchVCDidSelect(at point: OGPointModel)
}

class HakkaSearchVC: UIViewController {
    //MARK: - Enum
    enum TableViewType {
        case history
        case result
    }
    
    //MARK: - Variables
    var delegate: HakkaSearchVCDelegate?

    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var historyTitleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "HakkaSearchCell"
    private var tableViewType = TableViewType.history
    
    // History
    private let historyKey = "Omni_Hakka_Search_History_Key"
    private var historyList: [String] {
        if let list = UserDefaults.standard.array(forKey: historyKey) as? [String] {
            return list
        }else {
            return []
        }
    }
    
    private var pointList = [OGPointModel]()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: - IBActions
    @IBAction func closeViewDidTapped(_ sender: Any) {
        textField.text = nil
        tableViewType = .history
        reloadViews()
    }
    
    @IBAction func clearHistoryBtnPressed(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: historyKey)
        reloadViews()
    }
    
    //MARK: - Functions
    private func reloadViews() {
        view.endEditing(true)
        historyTitleView.isHidden = (tableViewType == .result)
        tableView.reloadData()
    }
    
    private func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func backBtnPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Setup Views
    private func setupViews() {
        title = "搜尋"
        NaviUtility.CustomBackBarButtonItem(self, action: #selector(backBtnPressed), image: NAVIAsset.btn_back.img)
        searchImageView.image = NAVIAsset.map_btn_search.img.withRenderingMode(.alwaysTemplate)
        searchImageView.tintColor = NaviProject.color
    }
}

//MARK: - UITableView Data Source / Delegate
extension HakkaSearchVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewType == .history {
            return historyList.count
        }else {
            return pointList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HakkaSearchCell
        if tableViewType == .history {
            let keyword = historyList[indexPath.row]
            cell.setup(point: nil, title: keyword, type: tableViewType)
        }else if tableViewType == .result {
            let point = pointList[indexPath.row]
            cell.setup(point: point, title: nil, type: tableViewType)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if tableViewType == .history && index < historyList.count {
            textField.text = historyList[index]
            search()
        }else if tableViewType == .result && index < pointList.count {
            let point = pointList[index]
            delegate?.hakkaSearchVCDidSelect(at: point)
            navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - UITextField Delegate
extension HakkaSearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        return true
    }
}

//MARK: - History
extension HakkaSearchVC {
    private func saveKeyword(with keyword: String) {
        guard !historyList.contains(keyword) else {
            return
        }
        var bufferList = historyList
        if bufferList.count == 10 {
            bufferList.removeFirst()
        }
        bufferList.append(keyword)
        UserDefaults.standard.set(bufferList, forKey: historyKey)
    }
}

//MARK: - Search
extension HakkaSearchVC {
    private func search() {
        guard let keyword = textField.text else {
            return
        }
        
        saveKeyword(with: keyword)
        tableViewType = .result
        
        LoadingAnimation.shared.start(title: "搜尋中...")
        
        let lat = LocationBase.shared.coordinate.latitude
        let lng = LocationBase.shared.coordinate.longitude
        let api = NaviUtility.GetFloorAPI + "&keyword=\(keyword)&lat=\(lat)&lng=\(lng)"
        
        pointList.removeAll()
        
        HTTPSClient().getEncodedData(api, token: nil, completion: searchCompletionHandler(_:))
    }
    
    private func searchCompletionHandler(_ data: Data?) {
        LoadingAnimation.shared.stop()
        
        guard let data else {
            DispatchQueue.main.async {
                self.showAlert(title: "錯誤", message: "無法取得搜尋結果，請稍後再試。")
                self.reloadViews()
            }
            return
        }
        
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data)
            
            guard
                let jsonDic = jsonData as? [String: Any],
                let result = jsonDic["result"] as? String,
                result == "true"
            else {
                DispatchQueue.main.async {
                    self.showAlert(title: "錯誤", message: "無法取得搜尋結果，請稍後再試。")
                    self.reloadViews()
                }
                return
            }
            
            let array = jsonDic["data"] as? [[String: Any]] ?? []
            array.forEach({floor in
                if let pois = floor["pois"] as? [[String: Any]] {
                    let number = floor["number"] as? Int ?? 0
                    pois.forEach({poi in
                        var point = poi
                        point["number"] = number
                        let pointModel = OGPointModel(data: point)
                        self.pointList.append(pointModel)
                    })
                }
            })
            
            DispatchQueue.main.async {
                self.reloadViews()
            }
        }catch {
            DispatchQueue.main.async {
                self.showAlert(title: "錯誤", message: error.localizedDescription)
                self.reloadViews()
            }
        }
    }
}
