//
//  CustomToogleButton.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/20.
//

import UIKit

class CustomToggleButton: UIButton {
    
    enum ToogleState {
        case selected
        case unselect
    }
    
    var toogleState: ToogleState = .unselect {
        didSet {
            updateButtonImage()
        }
    }
    
    var selectedImage: UIImage? {
        didSet {
            updateButtonImage()
        }
    }
    
    var unselectImage: UIImage? {
        didSet {
            updateButtonImage()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        
        updateButtonImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
        
        setup()
        
        updateButtonImage()
    }
    
    private func setup() {
        selectedImage = UIImage(named: "selectedCircle", in: Bundle(for: MissionViewController.self), compatibleWith: nil)
        
        unselectImage = UIImage(named: "unselectCircle", in: Bundle(for: MissionViewController.self), compatibleWith: nil)
        
        
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center
        
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    
    @objc private func buttonTapped() {
        
        toogleState = toogleState == .unselect ? .selected : .unselect
        
    }
    
    private func updateButtonImage() {
        let animationDuration: TimeInterval = 0.5
        let animationScale: CGFloat = 0.5
        
        switch toogleState {
        case .selected:
            if let imageView = self.imageView {
                UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
                    imageView.transform = CGAffineTransform(scaleX: animationScale, y: animationScale)
                }) { _ in
                    self.setImage(self.selectedImage, for: .normal)
                    
                    UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
                        imageView.transform = .identity
                    }, completion: nil)
                    
                    // 震動反饋
                    let feedbackGenerator = UISelectionFeedbackGenerator()
                    feedbackGenerator.selectionChanged()
                }
            }
            
        case .unselect:
            self.setImage(unselectImage, for: .normal)
        }
    }
}
