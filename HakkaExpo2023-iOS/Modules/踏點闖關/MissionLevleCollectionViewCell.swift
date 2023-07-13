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

    func configure(with nineGrid: NineGrid, levelNumber: Int) {
        
        let bundle = Bundle(for: MissionLevleCollectionViewCell.self)
        
//        guard let levelID = nineGrid.id else { return }
        bitmapImageView.image = UIImage(named: "bitmap\(levelNumber)", bundle: bundle)
        
        guard let isFinshed = nineGrid.isComplete else { return }
        finishImageView.isHidden = !isFinshed ? true : false
    }
}
