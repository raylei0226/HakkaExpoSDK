//
//  awardTicketViewModel.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/12.
//

import UIKit

protocol AwardTicketViewModelObserver: AnyObject {
    func awardTicketUpdated(_ tickets: [String])
}

class AwardTicketViewModel {
    
    var observers: [AwardTicketViewModelObserver] = []
    
    
}
