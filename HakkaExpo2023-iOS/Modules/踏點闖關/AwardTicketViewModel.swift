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
    
    private var awardItems: [String] = []
    
    var observers: [AwardTicketViewModelObserver] = []
    
    var itemsData: AwardTicketData?
    
    var numberOfItems: Int {
        return awardItems.count
    }
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        RestAPI.shared.getAward(MissionApiType.reward.rawValue) { data in
            guard let data = data else { return }
            print("獎勵:\(data)")
            self.itemsData = data
            self.updateAwardItems()
        }
    }
    
    private func updateAwardItems() {
        if let item = itemsData?.data?.compactMap({ $0.mTitle }) {
            awardItems = item
        }
        notifyObservers()
    }
    
    private func notifyObservers() {
        for observer in observers {
            observer.awardTicketUpdated(awardItems)
        }
    }
        
    func getItem(at index: Int) -> TicketData {
        
        guard index >= 0 && index < awardItems.count else { return TicketData()}
        
        return (itemsData?.data?[index])!
    }
}
