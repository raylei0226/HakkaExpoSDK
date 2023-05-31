//
//  MainPageViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/19.
//

import Foundation
import UIKit
import SVProgressHUD

typealias hud = SVProgressHUD

@objc public class MainPageViewController: UIViewController {
    
    @IBOutlet weak var carouselCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var toOfficialWebsiteButton: UIButton!
    
    
    private let carouselViewModel = MainPageViewModel()
    private var timer: Timer?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //取得裝置DeviceID
        let deviceID = DeviceIDManager.getDeviceID()
        print("裝置ID: \(deviceID)")
        
        //監聽網路狀態
        Reachability.shared.startNetworkReachabilityObserver()
        
        //註冊cell
        carouselCollectionView.register(UINib(nibName: "CarouselCollectionViewCell", bundle: Bundle(for: MainPageViewController.self)), forCellWithReuseIdentifier: Configs.CellNames.carouselCollectionViewCell)
        
        //設置page control 總數
        pageControl.numberOfPages = carouselViewModel.numberOfItems
        
        startTimer()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    

    @objc private func scrollToNextPage() {
        guard let currentIndexPath = carouselCollectionView.indexPathsForVisibleItems.first else {
            return
        }
        
        let nextItem = currentIndexPath.item + 1
        let nextIndexPath = IndexPath(item: nextItem % carouselViewModel.numberOfItems, section: currentIndexPath.section)
        
        carouselCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        
        //tag 1:前往官網 2:踏點闖關 3:360環景 4:智慧導引 5:AR互動 6:退出 7:更多
        switch sender.tag {
            
        case 1: print(sender.tag)
        case 2: print(sender.tag)
        case 3: Router.shared.navigateToPanorama(self)
        case 4: print(sender.tag)
        case 5: print(sender.tag)
        case 6: self.dismiss(animated: true)
        case 7: print(sender.tag)
        default:
            break
            
        }
    }
}


extension MainPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return carouselViewModel.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Configs.CellNames.carouselCollectionViewCell, for: indexPath) as? CarouselCollectionViewCell else { return UICollectionViewCell() }
        
        let imageName = carouselViewModel.getItems(at: indexPath.item)
        
        cell.cofigure(with: imageName)

        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return carouselCollectionView.frame.size
    }

    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        stopTimer()
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        pageControl.currentPage = currentPage
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        pageControl.currentPage = currentPage
    
        startTimer()
        
//        let visibleRect = CGRect(origin: carouselCollectionView.contentOffset, size: carouselCollectionView.bounds.size)
//        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//        if let visibleIndexPath = carouselCollectionView.indexPathForItem(at: visiblePoint) {
//            pageControl.currentPage = visibleIndexPath.item
//
//
//        }
    }
}
