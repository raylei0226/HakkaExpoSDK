//
//  MissionLevleCollectionViewCell.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/13.
//

import UIKit

class MissionLevleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bitmapImageView: UIImageView!
    @IBOutlet weak var finishImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with number: Int) {
        let bundle = Bundle(for: MissionLevleCollectionViewCell.self)
        bitmapImageView.image = UIImage(named: "bitmap\(number)", bundle: bundle)
       
        let randomInt = [3, 5, 6, 7, 9].randomElement()
        finishImageView.isHidden = (number == randomInt) ? true : false
    }
}
