//
//  MainPageViewModel.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/23.
//

import UIKit

class MainPageViewModel {
    
    private var carouselItems: [String] = []
    
    var numberOfItems: Int {
        return carouselItems.count
    }
    
    init() {
        
        carouselItems = ["pic1", "pic2", "pic3"]
    }
    
    
    func getItems(at index: Int) -> String {
        
        guard index >= 0 && index < carouselItems.count else { return "" }
        
        return carouselItems[index]
    }
}

