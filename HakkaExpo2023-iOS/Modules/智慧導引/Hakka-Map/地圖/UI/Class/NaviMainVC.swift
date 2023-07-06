//
//  NaviMainVC.swift
//  NAVISDK
//
//  Created by Jimmy Zhong on 2019/10/8.
//  Copyright © 2019 omniguider. All rights reserved.
//

import UIKit
import GoogleMaps

protocol NaviMainVCDelegate: AnyObject {
    func didOpenPoiDetail(from naviMainVC: NaviMainVC, _ poi: OGPointModel)
    func didOpenDivision()
}

@objc class NaviMainVC: UIViewController {
    weak var delegate: NaviMainVCDelegate?
    
    enum ModeType {case none, navigationMode, searchMode, chooseMode}
    
    @IBOutlet weak var loadingBackView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var selectionViewLeading: NSLayoutConstraint!
    @IBOutlet weak var poiDetailTop: NSLayoutConstraint!
    
    private var timer: Timer?
    private var isLoading = false
    private var isSelectionMode: Bool {
        return selectionViewLeading.constant != 0
    }
    private var modeType = ModeType.none
    private var isStartGuideFromRowView = false
            
    var rightBarBtnItems: [UIBarButtonItem]?
    var mapVC: MapVC!
    var poiDetailVC: PoiDetailVC!
    var keyword: String!
    var poi: OGPointModel?
    var poiId: Int!
    var floorNumber: Int!
    var nearbyType: NearbyType!
    var didChooseGatherPoi: ((OGPointModel) -> Void) = {_ in}
    var selectedDeviceId = ""
    var oriSearchBarHeight: CGFloat!
    
    private var searchedPoint: OGPointModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViews()
        self.setupGatherPoi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.determineQuickGuide()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if searchedPoint != nil {
            mapVC.search(searchedPoint!)
            searchedPoint = nil
        }
    }
    
    private func setupGatherPoi() {
        self.mapVC.didChooseGatherPoi = self.didChooseGatherPoi
    }
    
    private func initViews() {
        title = NaviProject.usedProjectModel.titleName
        NaviUtility.CustomBackBarButtonItem(self, action: #selector(back), image: NAVIAsset.btn_back.img)
        NaviUtility.CustomRightBarButtonItem(self, action: #selector(searchBtnPressed), image: NAVIAsset.map_btn_search.img)
        mapVC.updateLocateBtn(Paras.locateBtnBottom)
    }
    
    @objc private func searchBtnPressed() {
        let vc = UIStoryboard(name: "HakkaSearch", bundle: Bundle(for: NaviMainVC.self)).instantiateInitialViewController() as! HakkaSearchVC
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func determineQuickGuide() {
        GlobalState.nearbyType = self.nearbyType
        
        guard let nearbyType = self.nearbyType else {
            return
        }

        NaviUtility.checkIsInProjectRegion(completion: {isInProjectRegion,coordinate in
            if (isInProjectRegion == true) || NaviUtility.NeedAnyWhereTest {
                self.mapVC.getQuickGuideRoute(type: nearbyType)
            }else {
                NaviUtility.ShowConfirmAlert("您不在場域", confirm: "確認", message: "將顯示預設點位至目的地的路線", confirmHandler: {[weak self] in
                    var beginPoiId = NaviProject.beginPoiId
                    //如果目的地是出口，就將起點改為出口旁服務台
                    if nearbyType == .Exit {
                        beginPoiId = "31"
                    }
                    
                    let poi = NaviUtility.GetPoiBy(Int(beginPoiId)!)
                    GlobalState.beginName = poi?.name ?? ""
                    self?.mapVC.getQuickGuideRoute(type: nearbyType, userPostion: poi?.coordinate)
                })
            }
        })
        self.nearbyType = nil
    }
    
    @objc private func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func endNavigationMode() {
        self.mapVC.updateLocateBtn(Paras.locateBtnBottom)
        self.poiDetailVC.view.isHidden = false
        self.poiDetailVC.collapse()
        self.setLoading(false)
        self.title = NaviProject.usedProjectModel.titleName
        self.navigationItem.rightBarButtonItems = rightBarBtnItems
    }
    
    @IBAction func loadingBackViewTapped(_ sender: Any) {
        self.putBackSelectionViewIfNeeded()
    }
    
    private func putBackSelectionViewIfNeeded() {
        if !isSelectionMode {
            return
        }
        selectionViewLeading.constant = 0
        loadingBackView.isHidden = true
        UIView.animate(withDuration: 0.25, animations: {self.view.layoutSubviews()})
    }
    
    @objc func pressBackItem(_ sender: Any) {
        switch self.modeType {
        case .navigationMode:
            if isStartGuideFromRowView {
                isStartGuideFromRowView = false
            }else {
                self.endNavigationMode()
                self.mapVC.leavePreview()
                GlobalState.nearbyType = nil
                NaviUtility.CustomLeftBarButtonItem(self, action: #selector(self.back))
                NaviUtility.CustomRightBarButtonItem(self, action: #selector(searchBtnPressed), image: NAVIAsset.map_btn_search.img)
            }
        case .searchMode:
            self.modeType = .navigationMode
            self.mapVC.endSearchMode()
        case .chooseMode:
            self.modeType = .navigationMode
            self.mapVC.endChooseMode(with: true)
        case .none:
            break
        }
    }
    
    private func setLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
        loadingBackView.isHidden = !isLoading
        isLoading ? indicator.startAnimating() : indicator.stopAnimating()
    }
    
    private func setupViews() {
        title = NaviProject.usedProjectModel.titleName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "map":
            self.mapVC = (segue.destination as! MapVC)
            self.mapVC.mapDelegate = self
            self.mapVC.mapNavigationDelegate = self
            self.mapVC.markerMode = GlobalState.markerMode
            self.mapVC.selectedDeviceId = GlobalState.selectedDeviceId
        case "poiDetail":
            self.poiDetailVC = (segue.destination as! PoiDetailVC)
            self.poiDetailVC.initialize(.normal, delegate: self, panDelegate: self)
        default:
            return
        }
    }
    
    private func prepareGuide(to point: OGPointModel) {
        NaviUtility.checkIsInProjectRegion(completion: {isInProjectRegion,coordinate in
            if NaviUtility.ManualSimulateMode {
                guard let tappedCoordinate = GlobalState.tappedCoordinate else {
                    return
                }
                self.prepareRoute(to: point, from: tappedCoordinate)
            }else if isInProjectRegion {
                self.prepareRoute(to: point, from: coordinate)
            }else {
                NaviUtility.ShowConfirmAlert("您不在場域", confirm: "確認", message: "將顯示預設點位至目的地的路線", confirmHandler: {[weak self] in
                    
                    let beginPoiId = NaviProject.beginPoiId
                    let poi = NaviUtility.GetPoiBy(Int(beginPoiId)!)
                    
                    GlobalState.beginName = poi?.name ?? ""
                    
                    self?.prepareRoute(to: point, defaultPoiId: beginPoiId)
                })
            }
        })
    }
}

//MARK: - Poi Row View Delegate
extension NaviMainVC {
    func didEndGuide() {
        self.mapVC.navStateDidPressEnd()
    }
}

//MARK: - Map Delegate
extension NaviMainVC: MapDelegate {
    func map(didSelect marker: GMSMarker) {
        guard let poi = NaviUtility.GetPoiModel(by: marker) else {
            return
        }
        
        GlobalState.endPoi = poi
        self.movePoiInfoPad(.up, poi)
    }
    
    func mapDidTapAtCoordinate() {
        self.movePoiInfoPad(.down, nil)
    }
    
    func movePoiInfoPad(_ direction: SlideDirection, _ poiModel: OGPointModel?) {
        if direction == .up {
            self.poiDetailVC.update(with: poiModel!)
        }else {
            self.poiDetailVC.collapse()
        }
    }
}


//MARK: - Map Navigation Delegate
extension NaviMainVC: MapNavigationDelegate {
    func mapDidStartNavigation() {
        self.movePoiInfoPad(.up, GlobalState.endPoi)
        self.modeType = .navigationMode
        self.poiDetailVC.view.isHidden = true
        self.hidePoiDetail()
        self.setLoading(false)
        self.title = "路徑規劃"
        NaviUtility.CustomLeftBarButtonItem(self, action: #selector(self.pressBackItem))
        self.navigationItem.rightBarButtonItems = nil
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.4431372549, blue: 0.7137254902, alpha: 1)
    }
    
    func mapDidStartSmartGuider() {
    }
    
    func mapDidEndSmartGuider() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: NAVIAsset.btn_back.img, style: .plain, target: self, action: #selector(pressBackItem))
    }
    
    func mapNavigationFailed() {
        self.endNavigationMode()
    }
    
    func mapDidStartSearchMode() {
        self.modeType = .searchMode
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: NAVIAsset.btn_back.img, style: .plain, target: self, action: #selector(pressBackItem))
    }
    
    func mapDidEndSearchMode() {
        self.modeType = .navigationMode
    }
    
    func mapDidStartChooseMode() {
        self.modeType = .chooseMode
    }
}

//MARK: - Poi Detail Position/Delegate
extension NaviMainVC: PoiDetailDelegate {
    func poiDetail(didPressedNaviTo point: OGPointModel) {
        self.prepareGuide(to: point)
    }
        
    private func prepareRoute(to point: OGPointModel, from coordinate: CLLocationCoordinate2D) {
        self.mapVC.getRoute(apiType: .coordinateToPoint, from: coordinate, to: point)
    }
    
    private func prepareRoute(to point: OGPointModel, defaultPoiId: String) {
        self.mapVC.getRoute(apiType: .pointToPoint, from: defaultPoiId, to: point)
    }
    
    func poiDetail(didPressedCollect p_id: Int) {
        self.setLoading(true)
    }
    
    func poiDetailDidEndCollect() {
        self.setLoading(false)
    }
    
    func hidePoiDetail() {
        poiDetailTop.constant = 0
    }
}

//MARK: - Poi Detail Pan Delegate
extension NaviMainVC: PoiDetailPanDelegate {
    func poiDetailPan(didCollapse height: CGFloat) {
        poiDetailTop.constant = -height
        self.mapVC.updateLocateBtn(Paras.locateBtnBottom + height)
        self.panAnimate(.up)
    }
    
    func poiDetailPan(didExpandFully height: CGFloat) {
        let botInset = view.safeAreaInsets.bottom
        let topInset = view.safeAreaInsets.top
        let max = view.frame.height - topInset - botInset
        poiDetailTop.constant = -min(max, height)
        self.panAnimate(.down)
    }
    
    func panAnimate(_ direction: SlideDirection) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutSubviews()
        }, completion: {_ in
            self.poiDetailVC.titleView.swipeBar.setSlideIcon(direction: direction, bundle: Bundle(for: PoiDetailVC.self))
        })
    }
}

//MARK: - NewSearchVC Delegate
extension NaviMainVC: HakkaSearchVCDelegate {
    func hakkaSearchVCDidSelect(at point: OGPointModel) {
        searchedPoint = point
    }
}
