//
//  PanoramaViewModel.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/30.
//

import UIKit

protocol PanoramaViewModelObserver: AnyObject {
    func panoramaItemsUpdate(_ items: [String])
}

class PanoramaViewModle {
    
    private var panoramaItems: [String] = []
    
    var observers: [PanoramaViewModelObserver] = []
    
    var itemsData: PanoramaData?
    
    var numberOfItems: Int {
        return panoramaItems.count
    }
    
    init() {
        fetchData()
    }

    func fetchData() {
        RestAPI.shared.getPano360 { data in
            guard let data = data else { return }
            self.itemsData = data
            self.updataPanoramaItems()
        }
    }
    
    private func updataPanoramaItems() {
        if let items = itemsData?.data?.compactMap({$0.image}) {
            panoramaItems = items
        }
        notifyObservers()
    }
    
    private func notifyObservers() {
        for observer in observers {
            observer.panoramaItemsUpdate(panoramaItems)
        }
    }
    
    func getItems(at index: Int) -> (String, String) {

        guard index >= 0 && index < panoramaItems.count else { return ("", "")}
        
        guard let name = itemsData?.data?[index].name else { return ("", "")}
        
        return (panoramaItems[index], name)
    }
}
