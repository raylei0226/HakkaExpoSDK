//
//  ItemsMenu.swift
//  TaipeiSmartStation
//
//  Created by  Jolly on 2017/3/20.
//
//

import UIKit

// This is you popover's class
protocol floorMenuDelegate: AnyObject {
    func didPickFloor(number: Int, dispatchGroup: DispatchGroup?)
}

class FloorMenuVC: UITableViewController {
    weak var delegate: floorMenuDelegate?
    
    var floorNumbers: [Int] = []
    var pickedFloorNumber: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 76
        self.setBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func reloadFloorNumbers(pickedNumber: Int) {
        self.pickedFloorNumber = pickedNumber
        self.floorNumbers = NaviUtility.GetFloorNumbers()
        self.tableView.reloadData()
        self.scrollToPickedRow(floorNumbers: self.floorNumbers, pickedNumber: self.pickedFloorNumber)
    }
    
    func scrollToPickedRow(floorNumbers: [Int], pickedNumber: Int) {
        for i in 0..<floorNumbers.count {
            if floorNumbers[i] == pickedNumber {
                self.tableView.scrollToRow(at: IndexPath(row: i, section: 0), at: .middle, animated: false)
                return
            }
        }
    }
    
    func setBackground() {
        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = false
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.floorNumbers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "floorCell", for: indexPath) as! TableViewCell
        cell.backgroundColor = UIColor.clear
        cell.setFloorText(number: self.floorNumbers[indexPath.row], pickedNumber: self.pickedFloorNumber)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didPickFloor(number: self.floorNumbers[indexPath.row], dispatchGroup: nil)
    }
}
