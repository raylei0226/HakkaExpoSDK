//
//  MissionLevelViewModel.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/15.
//

import UIKit

protocol MissionLevelViewModelObserver: AnyObject {
    func missionLevelItemsUpdated(_ levelItems: [String], _ isFinshed: Bool)
}

class MissionLevelViewModel {
    
    private var missionLevelItems: [String] = []
    
    private var mID: String?
    
    var observers: [MissionLevelViewModelObserver] = []
    
    var isFinshed: Bool = false
    
    var levelItemsData: NineGridData?
  
    var numberOfItems: Int {
        return missionLevelItems.count
    }
 
    init(missionID: String) {
        self.mID = missionID
        fetchData()
    }
    
    func fetchData() {
        HudManager.shared.showProgress()
        guard let mid = mID else { return }
        RestAPI.shared.getNineGrid(mid) { data in
            guard let data = data else {
                HudManager.shared.showError(withMessage: K.errorMessage)
                return }
            self.levelItemsData = data
            self.updatedMissionLevel()
            HudManager.shared.hide()
        }
    }
    
    func convertSequence() -> [Int] {
        var numberSequence: [Int] = []
        for i in 1...numberOfItems {
            numberSequence.append(i)
        }
        return numberSequence
    }
    
    private func updatedMissionLevel() {
        if let items = levelItemsData?.data?.nineGrid?.compactMap({ $0.title }) {
            missionLevelItems = items
        }
        if let isFinished = levelItemsData?.data?.isFinish {
            self.isFinshed = isFinished
        }
        
        notifyObservers()
    }
    
    private func notifyObservers() {
        for observer in observers {
            observer.missionLevelItemsUpdated(missionLevelItems, isFinshed)
        }
    }
    
    func getModel(at index: Int) -> NineGrid {
        
        guard index >= 0 && index < missionLevelItems.count else { return NineGrid()}
        
        return (levelItemsData?.data?.nineGrid?[index])!
    }
    
    func getGridInfo() -> GridInfoData {
        
        guard let data = levelItemsData?.data else { return GridInfoData() }
        
        return data
    }
}
