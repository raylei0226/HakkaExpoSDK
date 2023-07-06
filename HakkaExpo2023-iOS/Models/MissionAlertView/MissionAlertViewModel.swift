//
//  MissionAlertViewModel.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/8.
//

class MissionAlertViewModel {
    
    var alertType: MLAlertViewType!
    
    var title: String?
    var message: String?
    var secondMessage: String?
    
    init(alertType: MLAlertViewType) {
        self.alertType = alertType
        setupMessage()
    }
    
    private func setupMessage() {
        switch alertType {
        case .arrival:
            title = "抵達關卡"
            message = "請答題過關！\n"
        case .notYeyArrived:
            title = "尚未抵達關卡"
            message = "您尚未抵達關卡位置，\n請開啟GPS確認您的位置∙\n"
        case .correctAnswer:
            title = "答題正確"
            message = "恭喜答對過關！\n"
        case .receivedTheReward:
            secondMessage = "領取成功\n\n"
        case .touchdown:
            title = "已抵達目的地"
            message = "恭喜過關！"
        case .none:
            break
        }
    }
}

//
//struct AlertModel {
//    var title: String?
//    var message: String?
//    var secondMessage: String?
//}
