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
       let image = UIImage(named: imageName, in: Bundle(for: MainPageViewController.self), compatibleWith: nil)!
        imageView.image = image
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
