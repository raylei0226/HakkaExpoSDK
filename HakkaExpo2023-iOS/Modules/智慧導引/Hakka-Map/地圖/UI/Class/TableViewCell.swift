//
//  TableViewCell.swift
//  NAVISDK
//
//  Created by Jelico on 2021/5/17.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var lab1: UILabel!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var lab2: UILabel!
    @IBOutlet weak var pic: UIImageView!
    @IBOutlet weak var topDotStack: UIStackView!
    @IBOutlet weak var bottomDotStack: UIStackView!
    
    let projectColor = NaviProject.color
    
    func setFloorText(number: Int, pickedNumber: Int) {
        let floorName = NaviUtility.GetFloorName(by: number)
        
        self.lab1.text = floorName
        self.lab1.textColor = (number == pickedNumber) ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : self.projectColor
        
        self.view1.layer.cornerRadius = self.view1.frame.width / 2
        self.view1.backgroundColor = (number == pickedNumber) ? self.projectColor : UIColor.clear
        
        if number == pickedNumber {
            self.view1.layer.addShadow()
        }else {
            self.view1.layer.shadowOpacity = 0
        }
    }
    
    func setPic(_ imageStr: String) {
        guard
            let url = URL(string: imageStr),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
        else {
            return
        }
        
        self.pic.image = image
    }
}
