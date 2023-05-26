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
        pageControl.currentPage = 0
        
    }
    
    
   
    @IBAction func buttonClicked(_ sender: UIButton) {
        
        //tag 1:前往官網 2:踏點闖關 3:360環景 4:智慧導引 5:AR互動 6:退出 7:更多
        switch sender.tag {
            
        case 1: print(sender.tag)
        case 2: print(sender.tag)
        case 3: print(sender.tag)
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
        
//        let imageName = carouselViewModel.getItems(at: indexPath.item)
//
//        cell.cofigure(with: imageName)
        let imageArray = [ UIImage(named: "pic1"), UIImage(named: "pic2")]
        cell.imageView.image = imageArray[indexPath.row]
    
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: carouselCollectionView.bounds.width, height: carouselCollectionView.bounds.height)
    }
    
    
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let visibleRect = CGRect(origin: carouselCollectionView.contentOffset, size: carouselCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = carouselCollectionView.indexPathForItem(at: visiblePoint) {
            pageControl.currentPage = visibleIndexPath.item
        }
    }
    

    
    
}
