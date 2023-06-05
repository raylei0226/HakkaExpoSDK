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
//       let image = UIImage(named: imageName, in: Bundle(for: MainPageViewController.self), compatibleWith: nil)!
        let url = URL(string: imageURL)
        imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "pic1"))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
