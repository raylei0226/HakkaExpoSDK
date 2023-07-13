//
//  MainPageViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/19.
//

import Foundation
import UIKit
import SDWebImage
import SDWebImageWebPCoder
import Alamofire
import Firebase


 class MainPageViewController: UIViewController {

    @IBOutlet weak var carouselCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var toOfficialWebsiteButton: UIButton!
    @IBOutlet weak var mapImageView: UIImageView! {
        didSet {
            addTapGestureOnView(mapImageView)
        }
    }
    
    private var carouselViewModel =  MainPageViewModel()
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //取得裝置DeviceID
        let uuid = DeviceIDManager.shared.getDeviceID()
        
        GMSServices.provideAPIKey("AIzaSyCmLqkyCvz3QtQ-1uw7xPQX0TR1K71QZsA")
        
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        
        //監聽網路狀態
        Reachability.shared.startNetworkReachabilityObserver()
        
        //註冊cell
        carouselCollectionView.register(UINib(nibName: "CarouselCollectionViewCell", bundle: Bundle(for: MainPageViewController.self)), forCellWithReuseIdentifier: Configs.CellNames.carouselCollectionViewCell)
        carouselViewModel.observers.append(self)
    }

     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
     
     private func setupFBC() {
         let currentBundle = Bundle(for: MainPageViewController.self)
         guard
             let filePath = currentBundle.path(forResource: "GoogleService-Info", ofType: "plist"),
//             let filePath = currentBundle.path(forResource: "Hakka-GoogleService-Info", ofType: "plist"),
             let fileopts = FirebaseOptions(contentsOfFile: filePath)
         else {
             return
         }
         FirebaseApp.configure(options: fileopts)
     }
   
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func showWebView(_ url: String) {
        
        let webVC = CommonWebViewController(url: URL(string: url)!)
        
        self.navigationController?.show(webVC, sender: nil)
    }
    
    
    private func addTapGestureOnView(_ view: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showMapWebsite))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func showMapWebsite() {
        showWebView(Configs.Network.mapWebsite)
    }
    
    @objc private func showOfficialWebsite() {
        let webVC = CommonWebViewController(url: URL(string: Configs.Network.officialWebsite)!)
        
        self.navigationController?.show(webVC, sender: nil)
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
            
        case 1: showWebView(Configs.Network.officialWebsite)
        case 2: Router.shared.navigationToMission(self)
        case 3: Router.shared.navigateToPanorama(self)
        case 4: Router.shared.navigateToArMenu(self, .arNavigation)
        case 5: Router.shared.navigateToArMenu(self, .arInteraction)
        case 6: self.dismiss(animated: true)
        case 7: showWebView(Configs.Network.mapWebsite)
        default:
            break
        }
    }
}

//ViewModel Protocol
extension MainPageViewController: MainPageViewModelObserver {
    
    func carouselItemsUpdated(_ items: [String]) {
        DispatchQueue.main.async {
            self.pageControl.currentPage = self.carouselViewModel.numberOfItems
            self.startTimer()
            self.carouselCollectionView.reloadData()
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
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.showWebView(Configs.Network.officialWebsite)
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
