//
//  CustomSegmentedControl.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/9.
//

import UIKit

protocol CustomSegmentedControlDelegate: AnyObject {
    func changeToIndex(index: Int)
}

class CustomSegmentedControl: UIView {
    
    private var buttonTitles: [String]!
    private var buttonImages: [UIImage]?
    private var buttons: [UIButton] = []
    private var selectorView: UIView!
    private var _seletcedIndex: Int = 0
    
    public var selectedIndex: Int {
        return _seletcedIndex
    }
    
    var disableIndex: Int? {
        didSet {
            self.setDisabled(index: disableIndex)
        }
    }
    
    var selectorViewColor = UIColor.white
    var selectorTextColor = Configs.Colors.missionBlue
    var disableViewColor = Configs.Colors.disableViewGray
    var disableTextColor = UIColor.gray
    
    weak var delegate: CustomSegmentedControlDelegate?
    
    convenience init(frame: CGRect, buttonTitle: [String], buttonImages: [UIImage]?) {
        self.init(frame: frame)
        self.buttonTitles = buttonTitle
        self.buttonImages = buttonImages
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateView()
    }
    
    func setButtons(buttonTitles: [String], buttonImages: [UIImage]?) {
        self.buttonTitles = buttonTitles
        if let images = buttonImages {
            self.buttonImages = images
        }
        updateView()
    }
    
    
    
    func setIndex(index: Int) {
        buttons.forEach({ $0.setTitleColor(disableTextColor, for: .normal)})
        let button = buttons[index]
        _seletcedIndex = index
        button.setTitleColor(selectorTextColor, for: .normal)
        let selectorPosition = frame.width / CGFloat(buttonTitles.count) * CGFloat(index)
        UIView.animate(withDuration: 0.2) {
            self.selectorView.frame.origin.x = selectorPosition
        }
    }
    
    
    func setDisabled(index: Int?) {
        guard index != nil else { return }
        let button = buttons[index!]
        button.setTitleColor( disableTextColor, for: .normal)
        button.backgroundColor = disableViewColor
        //        button.isEnabled = false
        if let imageArray = buttonImages {
            button.setImage((index == 1 ? imageArray[3] : imageArray[1]), for: .normal)
        }
    }
    
    private func updateView() {
        createButton()
        configSelectorView()
        configStackView()
    }
    
    private func configStackView() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    private func configSelectorView() {
        
        let selectorWidth = frame.width / CGFloat(self.buttonTitles.count)
        selectorView = UIView(frame: CGRect(x: 0, y: self.frame.height - 3, width: selectorWidth, height: 3))
        selectorView.backgroundColor = selectorTextColor
        addSubview(selectorView)
        selectorView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
    }
    
    private func createButton() {
        
        buttons = [UIButton]()
        buttons.removeAll()
        subviews.forEach({ $0.removeFromSuperview() })
        
        for buttonTitle in buttonTitles {
            
            let button = UIButton(type: .custom)
            button.setTitle(buttonTitle, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
            button.setTitleColor(disableTextColor, for: .normal)
            // 設置圖片和標題之間的距離
            let spacing: CGFloat = 10
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
            buttons.append(button)
        }
        
        buttons[0].setTitleColor(selectorTextColor, for: .normal)
        buttons[0].setImage(buttonImages![0], for: .normal)
        setDisabled(index: 1)
    }
    
    @objc private func buttonAction(sender: UIButton) {
        for (buttonIndex, button) in buttons.enumerated() {
            let isSelectedButton = (button == sender)
            
            button.setTitleColor(isSelectedButton ? selectorTextColor : disableTextColor, for: .normal)
            button.backgroundColor = isSelectedButton ? selectorViewColor : disableViewColor
            
            guard let imageArray = buttonImages else { return }
            let selectedImageIndex = (buttonIndex * 2) % imageArray.count
            button.setImage(imageArray[isSelectedButton ? selectedImageIndex : selectedImageIndex + 1], for: .normal)
            
            if isSelectedButton {
                let selectorPosition = frame.width / CGFloat(buttonTitles.count) * CGFloat(buttonIndex)
                UIView.animate(withDuration: 0.3) {
                    self.delegate?.changeToIndex(index: buttonIndex)
                    self.setIndex(index: buttonIndex)
                    self.selectorView.frame.origin.x = selectorPosition
                }
            }
        }
    }
}

