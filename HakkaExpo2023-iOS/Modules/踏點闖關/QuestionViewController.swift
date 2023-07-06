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
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var optionOne: CustomToggleButton!
    @IBOutlet weak var optionTwo: CustomToggleButton!
    @IBOutlet weak var optionThree: CustomToggleButton!
    @IBOutlet weak var optionFour: CustomToggleButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var nineGrid: NineGrid?
    
    var optionsButtonArray: [CustomToggleButton]?
    
    var answer: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.optionsButtonArray = [optionOne, optionTwo, optionThree, optionFour]
        
        guard let data = nineGrid else { return }
        
        print("Data:\(data)")
       
        setupUI(data)
    }
    
    private func setupUI(_ data: NineGrid) {
        navigationItem.title = "踏點闖關"
        titleView.layer.cornerRadius = 12
        titleView.dropShadow()
        optionsView.layer.cornerRadius = 12
        optionsView.dropShadow()
        confirmButton.layer.cornerRadius = 12
        confirmButton.dropShadow()
        
        titleLabel.text = data.title
        let question = data.question
        questionLabel.text = question?.title
        optionOne.setTitle(question?.option1, for: .normal)
        optionTwo.setTitle(question?.option2, for: .normal)
        optionThree.setTitle(question?.option3, for: .normal)
        optionFour.setTitle(question?.option4, for: .normal)
        
        self.answer = question?.answer
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
