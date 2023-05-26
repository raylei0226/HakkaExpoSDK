//
//  CarouselCollectionViewCell.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/25.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    func cofigure(with imageName: String) {
        self.imageView.image = UIImage(named: imageName)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
