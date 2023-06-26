//
//  MainPageViewModel.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/23.
//

import UIKit

protocol MainPageViewModelObserver: AnyObject {
    func carouselItemsUpdated(_ items: [String])
}

class MainPageViewModel {
    
    private var carouselItems: [String] = []
    
    var observers: [MainPageViewModelObserver] = []
    
    var itemsData: BannerData? 
    
    var numberOfItems: Int {
        return carouselItems.count
    }
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        HudManager.shared.showProgress()
        RestAPI.shared.getTopBanner { data in
            guard let data = data else {
                HudManager.shared.showError(withMessage: K.errorMessage)
                return }
            self.itemsData = data
            self.updateCarouselItems()
            HudManager.shared.hide()
        }
    }
    
    private func updateCarouselItems() {
        if let items = itemsData?.data?.compactMap({ $0.bImage }) {
                carouselItems = items
            }
          notifyObservers()
        }
    
    
    private func notifyObservers() {
        for observer in observers {
            observer.carouselItemsUpdated(carouselItems)
        }
    }

    func getItems(at index: Int) -> String {
        
        guard index >= 0 && index < carouselItems.count else { return "" }
        
        return carouselItems[index]
    }
}

