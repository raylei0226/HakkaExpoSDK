//
//  QuestionViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/21.
//

import UIKit

class QuestionViewControler: BasicViewController {
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var optionOne: CustomToggleButton!
    @IBOutlet weak var optionTwo: CustomToggleButton!
    @IBOutlet weak var optionThree: CustomToggleButton!
    @IBOutlet weak var optionFour: CustomToggleButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var optionsButtonArray: [CustomToggleButton]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.optionsButtonArray = [optionOne, optionTwo, optionThree, optionFour]
        
        
        setupUI()
    }
    
    private func setupUI() {
        navigationItem.title = "踏點闖關"
        titleView.layer.cornerRadius = 12
        titleView.dropShadow()
        optionsView.layer.cornerRadius = 12
        optionsView.dropShadow()
        confirmButton.layer.cornerRadius = 12
        confirmButton.dropShadow()
        
    }
    
    @IBAction func optionsClicked(_ sender: CustomToggleButton) {
        
        print("TAG:\(sender.tag)")
        
        guard optionsButtonArray != nil else { return }
        
        for i in optionsButtonArray! {
            if i == sender {
                i.toogleState = .selected
            } else {
                i.toogleState = .unselect
            }
        }
   }
}
