//
//  CarouselCollectionViewCell.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/25.
//

import UIKit
import SDWebImage

class CarouselCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
   
    func cofigure(with imageURL: String) {
        let url = URL(string: imageURL)
        imageView.sd_setImage(with: url, placeholderImage: Configs.setupPlaceholderImage(in: MainPageViewController.self))
        imageView.contentMode = .scaleAspectFill
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
