//
//  MainPageViewModel.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/23.
//

import UIKit

class MainPageViewModel {
    
    private var carouselItems: [String] = [] 
    
    var itemsData: BannerData? 
    
    var numberOfItems: Int {
        return carouselItems.count
    }
    
    init() {
        
        if let items = itemsData?.data?.compactMap({$0.bURL}) {
            carouselItems = items
        }
    }
    
    
    func getItems(at index: Int) -> String {
        
        guard index >= 0 && index < carouselItems.count else { return "" }
        
        return carouselItems[index]
    }
}

