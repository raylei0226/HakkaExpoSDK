//
//  MissionAlertView.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/7.
//

import UIKit

class MissionAlertView: UIView {
    
    static let instance = MissionAlertView()
    
    var onClickConfirm: (() -> Void)?
    
    var alertType: MLAlertViewType!
    
    var viewModel: MissionAlertViewModel!
      
    @IBOutlet var mlParentView: UIView!
    @IBOutlet weak var mlLayerView: UIView!
    @IBOutlet weak var mlColseButton: UIButton!
    @IBOutlet weak var mlAlertInfoStackView: UIStackView!
    @IBOutlet weak var mlTitleLabel: UILabel!
    @IBOutlet weak var mlMessageLabel: UILabel!
    @IBOutlet weak var mlImageView: UIImageView!
    @IBOutlet weak var mlSuccessLabel: UILabel!
    @IBOutlet weak var mlConfirmButton: UIButton!
    
    
      override init(frame: CGRect) {
          super.init(frame: frame)
          
          let bundle = Bundle(identifier: Configs.BoundleID.id)
          bundle?.loadNibNamed("MissionAlertView", owner: self)
          commonInit()
      }
      
      required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
          commonInit()
      }
      
      func commonInit() {
          mlParentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
          mlParentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
          mlLayerView.layer.cornerRadius = 12
          mlConfirmButton.layer.cornerRadius = 12
      }
    
    func configure(with type: MLAlertViewType) {
        let vm = MissionAlertViewModel(alertType: type)
        self.viewModel = vm
        setupUI()
    }
    
    
      
      func configure(with viewModel: MissionAlertViewModel) {
          self.viewModel = viewModel
          setupUI()
      }
      
      func setupUI() {
          mlTitleLabel.text = viewModel.title ?? ""
          mlMessageLabel.text = viewModel.message ?? ""
          mlSuccessLabel.text = viewModel.secondMessage ?? ""
          
          switch viewModel.alertType {
          case .arrival, .correctAnswer, .touchdown:
              mlImageView.isHidden = true
              mlSuccessLabel.isHidden = true
          case .receivedTheReward:
              mlImageView.isHidden = false
              mlSuccessLabel.isHidden = false
          case .none:
              break
          }
          self.alertType = viewModel.alertType
          self.showAlert(with: alertType)
      }
    
    func showAlert(with type: MLAlertViewType) {
          UIApplication.shared.windows.first { $0.isKeyWindow }?.addSubview(mlParentView)
      }
    
    func showAlert() {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.addSubview(mlParentView)
    }
          
      @IBAction func closeAlert(_ sender: UIButton) {
          mlParentView.removeFromSuperview()
      }
      
      @IBAction func confirmButtonClicked(_ sender: UIButton) {
          onClickConfirm?()
      }
  }


//使用方式
//let viewModel = MissionAlertViewModel(alertType: .notYeyArrived)
//MissionAlertView.instance.configure(with: viewModel)
//MissionAlertView.instance.showAlert()
