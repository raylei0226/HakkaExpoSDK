//
//  MissionViewModel.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/14.
//

import UIKit

protocol MissionViewModelObserver: AnyObject {
    func missionItemsUpdated(_ missions: [String])
}

class MissionViewModel {
    
    private var missionItems: [String] = []
    
    var observers: [MissionViewModelObserver] = []
    
    var itemsData: MissionData?
    
    var numberOfItems: Int {
        return missionItems.count
    }
   
    init() {
        fetchData()
    }
    
    func fetchData() {
        HudManager.shared.showProgress()
        RestAPI.shared.getMission(MissionApiType.mission.rawValue) { data in
            guard let data = data else {
                HudManager.shared.showError(withMessage: K.errorMessage)
                return }
            self.itemsData = data
            self.updataMissionItems()
            HudManager.shared.hide()
        }
    }
    
    private func updataMissionItems() {
        if let items = itemsData?.data?.compactMap({ $0.mTitle }) {
            missionItems = items
        }
        notifyObservers()
    }
    
    private func notifyObservers() {
        for observer in observers {
            observer.missionItemsUpdated(missionItems)
        }
    }
    
    func getItems(at index: Int) -> (title: String, endTime: String, imgURL: String) {
        
        guard index >= 0 && index < missionItems.count else { return ("", "", "")}
        
        guard let missionEndTime = itemsData?.data?[index].mEndTime else { return ("", "", "")}
        
        guard let imageURL = itemsData?.data?[index].mImg else { return ("", "", "")}
        
        return(missionItems[index], missionEndTime, imageURL)
    }
    
    func getModel(at index: Int) -> MissionInfoData {
        
        guard index >= 0 && index < missionItems.count else { return MissionInfoData()}
        
        return (itemsData?.data?[index])!
        
    }
}
