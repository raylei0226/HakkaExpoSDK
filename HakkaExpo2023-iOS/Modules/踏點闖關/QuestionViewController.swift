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
    
    var option: String?
    
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
    
    private func checkAnswer(option: String) {
        
        if self.option == self.answer {
            guard let mID = UserDefaults.standard.value(forKey: K.missionID), let gID = nineGrid?.id else { return }
            RestAPI.shared.getMissionComplete(mID as! String, gID) { data in
                print("通關結果:\(String(describing: data?.data))")
                Router.shared.backToMissionLevel(self)
            }
            
        } else {
            
            guard let tip = nineGrid?.question?.tip else { return }
            
            let alert = UIAlertController(title: "關卡提示", message: "💡" + tip, preferredStyle: .alert)
            alert.modalPresentationStyle = .popover
            
            if #available(iOS 13.0, *) {
                alert.overrideUserInterfaceStyle = .light
            } else {
                // Fallback on earlier versions
            }
            
            let action = UIAlertAction(title: "知道了！", style: .default) { action in
                self.option = nil
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func optionsClicked(_ sender: UIButton) {
        
        if sender.tag == 55 {
            guard let option = option else {
                HudManager.shared.showError(withMessage: "請選擇答案")
                return
            }
            self.checkAnswer(option: option)
        }
        
        guard optionsButtonArray != nil else { return }
        
        for i in optionsButtonArray! {
            if i == sender {
                i.toogleState = .selected
                self.option = String(i.tag)
            } else {
                i.toogleState = .unselect
            }
        }
    }
}
