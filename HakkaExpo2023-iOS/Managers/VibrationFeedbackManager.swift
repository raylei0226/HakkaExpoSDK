//
//  VibrationFeedbackManager.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/7/3.
//

import AudioToolbox
import UIKit

class VibrationFeedbackManager {
    
    static let shared = VibrationFeedbackManager()
    
    private init() {}
    
    func playVibration() {
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
}
