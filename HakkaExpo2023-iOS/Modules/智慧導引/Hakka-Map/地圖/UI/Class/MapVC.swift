//
//  MapVC.swift
//
//  Created by Jimmy Zhong on 2019/10/9.
//  Copyright © 2019 omniguider. All rights reserved.
//
import UIKit
import GoogleMaps
import ClusterKit


protocol MapDelegate: AnyObject {
    func map(didSelect marker: GMSMarker)
    func mapDidTapAtCoordinate()
}

protocol MapNavigationDelegate: AnyObject {
    func mapDidStartNavigation()
    func mapNavigationFailed()
    func mapDidStartSmartGuider()
    func mapDidEndSmartGuider()
    func mapDidStartSearchMode()
    func mapDidEndSearchMode()
    func mapDidStartChooseMode()
}

@objc class MapVC: UIViewController {
    enum MapModeType {
        case simple
        case position
    }
    private(set) var currentMapMode = MapModeType.simple
    
    weak var mapDelegate: MapDelegate?
    weak var mapNavigationDelegate: MapNavigationDelegate?
        
    // Map
    @IBOutlet weak var locateBtnBottom: NSLayoutConstraint!
    @IBOutlet weak var locateBtn: UIButton!
    @IBOutlet weak var chooseBtn: UIButton!
    private let mapView = GMSMapView()
    
    // Navigation
    var navGuideVC: NavigationGuideVC!
    @IBOutlet weak var navGuideViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navGuideBottom: NSLayoutConstraint!
    var navBottomGuideVC: NavigationBottomGuideVC!
    @IBOutlet weak var navBottomGuideView: UIView!
    @IBOutlet weak var navBottomGuideViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navStateView: NavigationStateView!
    @IBOutlet weak var navDetailTop: NSLayoutConstraint!
    var navSearchVC: NavigationMapSearchVC!
    @IBOutlet weak var navSearchHeight: NSLayoutConstraint!
    let navPresenter = NavigationPresenter()
    @IBOutlet weak var floorLabCenter: NSLayoutConstraint!
    @IBOutlet weak var positionLabCenter: NSLayoutConstraint!
    @IBOutlet weak var searchLabRight: NSLayoutConstraint!
        
    @IBOutlet weak var chooseImageView: UIImageView!
    
    private var targetPoint: OGPointModel!
    private var poiGuideNavPoint: InfoPoint?
    private var poiGuideNavCoordinate: CLLocationCoordinate2D?
    
    //NAVISDK
    @IBOutlet weak var aacCategoryView: UIView!
    @IBOutlet weak var floorBtn: UIButton!
    @IBOutlet weak var floorContainer: UIView!
    @IBOutlet weak var floorContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewBottomView: UIView!
    
    var planModels: [PlanModel] = []
    var tileLayer: GMSURLTileLayer?
    var enteredPlanId: String?
    var pickedPlanId: String?
    var routeStartFloorNumber = 1
    var pickedFloorNumber = "1"
    var navBeginFloorNumber = "1"
    var enteredFloorNumber = "1"
    var enteredFloorName: String!
    var simulateEnteredFloorNumber: String!
    var pinchedZoom: Float!
    var isNavigating = false
    var showedDirectionMarkers: [GMSMarker] = []
    var directionMarkersList: DirectionMarkersListModel!
    var userMarker = OGMarker()
    var arrowMarker = GMSMarker()
    var showedMarkers: [GMSMarker] = []
    var showedFriendMarkers: [GMSMarker] = []
    var beginMarker = GMSMarker()
    var endMarker = GMSMarker()
    var userCoordinate: CLLocationCoordinate2D!
    var aacCategoryBtns = [UIButton]()
    var current_ac_id: Int!
    var current_aac_id = 0
    var current_aac_id_array: [Int] = [0]
    var currentFloor = 1
    var focusedPath: GMSMutablePath!
    var path1 = GMSMutablePath() //路線座標-座標
    var polyline1 = GMSPolyline() // 路線
    var backgroundPath1 = GMSPolyline() // 路線底色
    var path2 = GMSMutablePath()
    var polyline2 = GMSPolyline()
    var line1Bearing: Double! // 導航後每段路線之旋轉角度
    var segmentBeginIndex: UInt! // 最接近使用者路線段(segment)的起點
    var floorRouteDic = NSMutableDictionary() // 儲存不同樓層經緯度資料
    var arrowPosition: CLLocation!
    var showArrow = false //用來檢查是否要以箭頭為中心
    var arrowPendingTime = 0
    var cameraState = CameraState.fixNorth
    var beginPoiModel: OGPointModel!
    var endPoiModel: OGPointModel!
    var routeApiType: RouteApiType!
    var currentMapBearing: CLLocationDirection!
    
    var priority: Priority! = .normal
    enum Priority: String {
        case normal = ""
        case elevator = "elevator"
    }
    var currentCameraCoordinate: CLLocationCoordinate2D!
    var autoGuideTimer: Timer!
    var simulateCoordinates: [CLLocationCoordinate2D] = []
    var autoCount = 0
    var isAutoSimulate: Bool! = false
    var floorMenuVC: FloorMenuVC!
    var routeOrderMode: RouteOrderMode = .normal
    var normalRoute: [[String: Any]] = []
    var reversedRoute: [[String: Any]] = []

    //起點/目的地 位置＆樓層
    var endFloorNum: String!
    var endLocation: CLLocation?
    
    //每層樓終點機制
    var askIndex = 0
    var nodeCountArray: [Int] = []
    var endCoordinateArray: [CLLocation] = []
    var nextFloorNumArray: [String] = [] //
    var guideFloorAmount: Int!
    var needDetectTarget = false
    var beginCoordinateArray: [CLLocation] = []
    var lockedNextPlanID = ""

    //用於「偏離路徑重新計算」
    var nearestDistance: Double?
    var isRecaculateRoute = "no"
    var deviationTimer = Timer()

    //用來記錄「下一個marker」
    var lastMarker: GMSMarker!
    
    var originalIcon = UIImage()
    var zindexN: Int32 = 1
    var tappedPoiId = ""
    var hasTappedPoi: Bool!
    var userDirection: CLLocationDirection!
    var locateZoom: Float!
    var planBoundZoom: Float!

    //for clusters
    var markerAnnotations = [GMSMarkerAnnotation]()
    private var correctIndex: Int = 0
    
    //找朋友
    var markerMode: MarkerMode!
    var selectedDeviceId = ""
    var gatherTitle = UILabel()
    var gatherPoi: OGPointModel!
    var didChooseGatherPoi: ((OGPointModel) -> Void) = {_ in}
    var hasShowGatherPoiOnce = false
    
    //專案顏色
    let projectColor = NaviProject.color

    //是否允許地圖轉向
    private var isCanHeading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViews()
        self.prepare()
        self.setupFloorMenuVc()
        self.navPresenter.delegate = self
        self.navStateView.delegate = self
        self.setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addListen()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func showSearchLabel() {
        let animate = UIViewPropertyAnimator(duration: 1, curve: .easeOut)
        
        animate.addAnimations {
            self.searchLabRight.constant = 17
            self.view.layoutIfNeeded()
        }
        
        animate.addCompletion({_ in
            let animate2 = UIViewPropertyAnimator(duration: 1, curve: .easeOut)
            
            animate2.addAnimations {
                self.searchLabRight.constant = -100
                self.view.layoutIfNeeded()
            }
            animate2.startAnimation(afterDelay: 5)
        })
        
        animate.startAnimation(afterDelay: 1)
    }
    
    func addListen() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideCategoryView), name: .readyRouteData, object: nil)
    }
    
    private func initViews() {
        self.setupAacCategoryButtons()
        self.setupFloorBtnUI()

        self.floorLabCenter.constant = -100
        self.positionLabCenter.constant = 100
        self.searchLabRight.constant = -100
        self.navGuideViewHeight.constant = self.navGuideVC.trafficViewHeight.constant
                
        //偵測手勢平移-pan
        let pan = UIScreenEdgePanGestureRecognizer()
        pan.delegate = self
        self.view.addGestureRecognizer(pan)

        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: self.navStateView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        self.navStateView.layer.mask = maskLayer
        self.navStateView.isHidden = true
        locateBtn.imageView?.contentMode = .scaleAspectFit
        
        //挑選集合點
        if self.markerMode == .PickGatherPoint {
            self.showGatherView()
        }
    }
    
    func setupFloorMenuVc() {
        self.floorContainer.layer.cornerRadius = self.floorContainer.frame.width/2
        self.showFloorContainer(show: false)
        self.floorMenuVC = (UIStoryboard(name: "Map", bundle: Bundle(for: FloorMenuVC.self)).instantiateViewController(withIdentifier: "FloorMenuVC") as! FloorMenuVC)
        self.floorMenuVC.delegate = self
        NaviUtility.AddChildVc(controller: self, childVc: self.floorMenuVC, container: self.floorContainer)
        let btnCount: CGFloat = CGFloat(NaviUtility.GetFloorNumbers().count)
        floorContainerHeight.constant = floorContainer.bounds.width * btnCount + 14 * (btnCount - 1)
    }
    
    func setIsNavigating() {
        self.isCanHeading = true
        self.isNavigating = true
        self.needDetectTarget = true
        self.userMarker.map = nil
        self.tileLayer?.setOpacity(self.isNavigating)
    }
    
    @objc func hideCategoryView() {
        self.categoryView(isHidden: true)
    }
    
    func setupFloorBtnUI() {
        self.floorBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.floorBtn.titleLabel?.minimumScaleFactor = 0.1
        self.floorBtn.backgroundColor = self.projectColor
        self.floorBtn.setTitleColor(UIColor.white, for: .normal)
        self.floorBtn.layer.cornerRadius = self.floorBtn.frame.width / 2
        self.floorBtn.layer.addShadow()
    }
    
    func setupUserMarker() {
        self.userMarker.appearAnimation = GMSMarkerAnimation.pop
        self.userMarker.icon = NAVIAsset.blueDot.img
        self.userMarker.groundAnchor = CGPoint(x: 0.5, y: 19/29)
        self.userMarker.zIndex = 103
        self.userMarker.map = self.mapView
    }
    
    func setupArrowMarker() {
        self.arrowMarker.appearAnimation = GMSMarkerAnimation.pop
        self.arrowMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        self.arrowMarker.icon = NAVIAsset.nav_arrow.img
        self.arrowMarker.zIndex = 102
    }

    func categoryView(isHidden: Bool) {
        DispatchQueue.main.async {
            self.aacCategoryView.isHidden = isHidden
        }
    }

    func floorBtn(isHidden: Bool) {
        DispatchQueue.main.async {
            self.floorBtn.isHidden = isHidden
        }
    }
    
    @IBAction func pressLocateBtn(_ sender: Any) {
        //改變 cameraState 及 定位按鈕圖案
        self.cameraState = self.getNewCameraState(by: self.cameraState)
        self.changeLocateBtnState(cameraState: self.cameraState)

        //移動位置
        if self.isNavigating {
            self.moveToArrow()
        }else {
            self.moveToUser()
        }
        
        //切換樓層
        self.didPickFloor(number: Int(self.enteredFloorNumber)!, dispatchGroup: nil)
    }
    
    func moveToArrow() {
        self.pickedPlanId = self.enteredPlanId
        self.moveTo(location: self.arrowPosition, zoom: self.locateZoom)
        self.didPickFloor(number: Int(self.enteredFloorNumber)!, dispatchGroup: nil)
        RecordPressedLoc(loc: self.arrowPosition, type: .arrow)
    }
    
    func moveToUser() {
        guard let userLocation = self.getUserLocation() else {
            return
        }
        
        self.userMarker.position = userLocation.coordinate
        self.moveTo(location: userLocation, zoom: self.locateZoom)
        self.didPickFloor(number: Int(self.enteredFloorNumber)!, dispatchGroup: nil)
        RecordPressedLoc(loc: userLocation, type: .user)
    }
    
    func getUserLocation() -> CLLocation? {
        if NaviUtility.ManualSimulateMode {
            guard let tappedCoordinate = (GlobalState.tappedCoordinate) else {
                return nil
            }
            
            let lat = tappedCoordinate.latitude
            let lng = tappedCoordinate.longitude
            return CLLocation(latitude: lat, longitude: lng)
        }
        
        if (LocationBase.shared.enteredProjectPlanId != nil) || NaviUtility.NeedAnyWhereTest {
            return LocationBase.shared.location
        }else {
            return NaviProject.usedProjectModel.defaultPlanLocation
        }
    }
    
    func getNewCameraState(by cameraState: CameraState) -> CameraState {
        switch cameraState {
        case .flexible:
            return .fixUser
        case .fixUser:
            return .fixNorth
        case .fixNorth:
            return .fixUser
        }
    }
    
    //選擇任意起點
    @IBAction func pressChooseBtn(_ sender: Any) {
        //清除路徑資料
        self.clearRouteData()
        
        self.setChooseModeViews(true)
        self.navPresenter.renewInfo(nil, mapView.camera.target, type: .anyLocation)
        self.endSearchMode()
                
        self.userCoordinate = mapView.camera.target
        
        //設定起點名稱為「任意位置」
        GlobalState.beginName = self.navPresenter.anyPlaceText
        
        self.navBeginFloorNumber = self.pickedFloorNumber
        self.routeApiType = .coordinateToPoint
        self.navPresenter.getNaviRouteXyAPI(from: self.navBeginFloorNumber, beginCoordinate: self.userCoordinate, priority: self.priority.rawValue, endPoint: GlobalState.endPoi, dispatchGroup: nil)
    }
    
    func clearRouteData() {
        self.arrowMarker.map = nil // 移除箭頭
        self.beginMarker.map = nil // 移除起點
        self.endMarker.map = nil // 移除終點
        self.polyline1.map = nil // 清除路線圖
        self.backgroundPath1.map = nil
        self.polyline2.map = nil // 清除路線圖
        self.path1.removeAllCoordinates() // 清空路線資料
        self.path2.removeAllCoordinates() // 清空路線資料
        self.focusedPath.removeAllCoordinates() // 清空路線資料
        
        self.floorRouteDic.removeAllObjects() // 清除樓層number：經緯度
        self.endCoordinateArray.removeAll() //清空每樓層終點座標
        self.nodeCountArray.removeAll() //清空每樓層路線節點數
        self.nextFloorNumArray.removeAll() //清空樓層代碼
        self.askIndex = 0
        self.guideFloorAmount = nil
        self.beginPoiModel = nil
        self.endPoiModel = nil
    }

    func mapPresenter(didSelect marker: GMSMarker) {
        mapDelegate?.map(didSelect: marker)
    }
        
    func mapPresenterDidMoveMap() {
        locateBtn.setImage(UIImage(named: "map_unlocate", in: Bundle(for: MapVC.self), compatibleWith: nil), for: .normal)
    }
    
    //MARK: - Navigation
    func startPoiNavigation(to point: InfoPoint, from coordinate: CLLocationCoordinate2D) {
        poiGuideNavPoint = point
        poiGuideNavCoordinate = coordinate
    }
    
    //MARK: 開始導航
    func getRoute(apiType: RouteApiType, from coordinate: CLLocationCoordinate2D, to point: OGPointModel) {
        self.userMarker.map = nil
        self.targetPoint = (self.targetPoint == nil) ? point : self.targetPoint
                
        self.routeApiType = apiType
        self.navPresenter.getNaviRouteXyAPI(from: self.navBeginFloorNumber,
                                            beginCoordinate: coordinate,
                                            priority: self.priority.rawValue,
                                            endPoint: GlobalState.endPoi,
                                            dispatchGroup: nil)
    }
    
    func getRoute(apiType: RouteApiType, from defaultPoiId: String, to point: OGPointModel) {
        self.targetPoint = (self.targetPoint == nil) ? point : self.targetPoint
              
        self.routeApiType = apiType
        
        guard let coordinate = LocationBase.shared.coordinate else {
            return
        }
        GlobalState.beginName = navPresenter.currentPlaceText
        navPresenter.getNaviRouteXyAPI(from: navBeginFloorNumber, beginCoordinate: coordinate, priority: priority.rawValue, endPoint: point, dispatchGroup: nil)
    }
    
    func getQuickGuideRoute(type: NearbyType, userPostion: CLLocationCoordinate2D? = nil) {
        var coordinate: CLLocationCoordinate2D!
        if userPostion != nil {
            coordinate = userPostion
        }else if NaviUtility.ManualSimulateMode, let tappedCoordinate = GlobalState.tappedCoordinate {
            coordinate = tappedCoordinate
        }else if LocationBase.shared.coordinate != nil {
            coordinate = LocationBase.shared.coordinate
        }
        guard coordinate != nil else {
            return
        }
        
        self.mapView.padding.top = Paras.mapTopPadding
        self.routeApiType = .coordinateToPoint

        self.navPresenter.getNaviNearbyTypeAPI(from: self.enteredFloorNumber, coordinate: coordinate, type: type)
    }
    
    func leavePreview() {
        //任意位置 - 復原起點名稱「當前位置」
        self.navPresenter.setBeginNameDefault()
        
        //地圖搜尋-復原預設畫面
        self.navGuideVC.trafficVC.currentNavType = .userLocation
        
        //起終點回復預設順序
        self.navGuideVC.trafficVC.setDefaultRouteOrderMode()
        
        //回復為「一般路徑」模式
        self.priority = .normal
        self.navGuideVC.trafficVC.changeRouteBtn(tag: 0)
        
        self.mapView.animate(toViewingAngle: 0)
        
        self.categoryView(isHidden: false)
        self.floorBtn(isHidden: false)
        
        self.mapView.padding = .zero
        
        self.clearRouteData()
        self.tapMapRefresh()

        setNavViewsShowing(false)
    }
    
    private func setNavViewsShowing(_ isShow: Bool,_ isAnimated: Bool = true) {
        if isShow {
            let setHeight: CGFloat = 0
            self.navGuideBottom.constant = self.navGuideVC.trafficViewHeight.constant - setHeight
            self.navGuideVC.trafficViewHeight.constant -= setHeight
            self.navGuideViewHeight.constant = self.navGuideVC.trafficViewHeight.constant
        }else {
            self.navGuideBottom.constant = 0
        }

        setNavBottomGuideHidden(!isShow)
        if isShow {
            navBottomGuideVC.setup(with: targetPoint)
        }
        
        UIView.animate(withDuration: isAnimated ? 0.25 : 0, animations: {[weak self] in
            self?.view.layoutSubviews()
        })
    }
    
    func startSearchMode(_ isShowUserLocation:Bool) {
        mapNavigationDelegate?.mapDidStartSearchMode()
    }
    
    func endSearchMode() {
        UIView.animate(withDuration: 0, delay: 0, animations: {[weak self] in
            self!.navSearchHeight.constant = 0
            self?.view.layoutSubviews()
        })
    }
    
    func endChooseMode(with backBtn: Bool) {
        setChooseModeViews(true)
        setNavViewsShowing(true)
        updateLocateBtn(self.navStateView.viewHeight.constant + 16)
        startSearchMode(false)
    }
    
    //MARK: - Navigation Presenter Delegate
    func navPresenter(didLoad navModel: NavModel) {
        // UI Update
        setNavViewsShowing(true)
        updateLocateBtn(self.navStateView.viewHeight.constant + 16)
        mapNavigationDelegate?.mapDidStartNavigation()
    }
    
    func getShowedRoute(mode: RouteOrderMode) -> [[String: Any]] {
        return (mode == .reversed) ? self.reversedRoute : self.normalRoute
    }
    
    func prepareRoute(routeArray: [[String: Any]]) {
        //處理routeArray
        NaviUtility.HandleOriginalRouteData(routeArray: routeArray, completion: {a, b, c, d, e, f, g, h, i, j, k, l, m in
            let beginFloorNumber = a
            let beginLat = b
            let beginLng = c
            self.floorRouteDic = d
            self.nodeCountArray = e
            self.beginCoordinateArray = f
            self.endCoordinateArray = g
            self.nextFloorNumArray = h
            self.navBeginFloorNumber = i
            self.routeStartFloorNumber = Int(i)!
            self.endFloorNum = l
            self.endLocation = m
            let beginLocation = CLLocation(latitude: beginLat, longitude: beginLng)
                                        
            self.beginPoiModel = NaviUtility.CreatePoiModel(location: CLLocation(latitude: beginLat, longitude: beginLng), id: 10000, ac_id: 10000, floorNumber: Int(beginFloorNumber)!, name: "起點")
            self.endPoiModel = NaviUtility.CreatePoiModel(location: self.endLocation!, id: 10001, ac_id: 10001, floorNumber: Int(self.endFloorNum)!, name: "終點")

            //判斷是否直接提示「前往下一樓」
            self.determinePopReachMessage(nodeCountArray: self.nodeCountArray)

            //清除path
            self.path1.removeAllCoordinates()
            self.path2.removeAllCoordinates()
            
            //清除polyline
            self.polyline1.map = nil
            self.backgroundPath1.map = nil

            self.polyline2.map = nil
                    
            //用於didRefreshArrow()：從頭計算
            self.segmentBeginIndex = 0
            
            //起點的planId
            let beginPlanId = self.planModels.filter({$0.order == beginFloorNumber}).first?.plan_id

            //移動到起點
            self.moveTo(location: beginLocation, zoom: self.locateZoom)
                                        
            if let floorNumber = NaviUtility.GetFloorNumber(by: beginPlanId) {
                //切換樓層
                self.didPickFloor(number: Int(floorNumber)!, dispatchGroup: nil)
            }
                                        
            //顯示路線
            self.showPolyLine(floorNumber: beginFloorNumber, completion: {focusedPath in
                self.focusedPath = focusedPath
                NaviUtility.fitPath(path: self.focusedPath, mapView: self.mapView)
            })
        })
    }
    
    //判斷是否直接提示「前往下一樓」
    func determinePopReachMessage(nodeCountArray: [Int]) {
        guard nodeCountArray.count > 0 else {
            return
        }

        //起始樓層僅一個路線節點-直接提示「請前往x樓」
        if nodeCountArray[0] == 1 {
            let nextFloor = self.getNextFloor()
            self.lockedNextPlanID = nextFloor[2] as! String
            self.popReachedMessage(reachtType: .NextFloor, nextFloor: nextFloor)
        }
    }
    
    func popReachedMessage(reachtType: ReachType, nextFloor: [Any]) {
        //若已抵達目的地-關閉方向指引版
        if reachtType == .End {
            self.navGuideVC.hideInfoView()
        }

        let text = (reachtType == .End) ? Paras.reachTargetText : "\(Paras.nextFloorText)\(nextFloor[0])樓"

        let alert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "好", style: .default, handler: {action in
            guard
                nextFloor.count > 0,
                let nextIndex = nextFloor[1] as? Int
            else {
                return
            }
                                            
            //顯示下個平面圖
            self.showNaviNextTile(index: nextIndex)
            self.pickedPlanId = self.lockedNextPlanID
        })
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //取得導航的下個Floor、下個Index、下個planID
    func getNextFloor() -> [Any] {
        var floorText = ""
        var floorIndex:Int!
        var planID = ""
        
        for i in (self.askIndex + 1)..<self.nodeCountArray.count {
            if (self.nodeCountArray[i] > 1 || ( i == (self.nodeCountArray.count - 1)) && floorText == "") {
                floorText = self.nextFloorNumArray[i]
                
                //取得nextPlanID
                for plan in self.planModels {
                    if floorText == plan.order {
                        planID = plan.plan_id
                    }
                }
                
                floorIndex = i
                
                if floorText == "-1" {
                    floorText = "B1"
                }else if floorText == "-2" {
                    floorText = "B2"
                }
            }
        }
        return [floorText, floorIndex!, planID]
    }
    
    func showNaviNextTile(index: Int) {
        guard
            let nextPlanModel = self.planModels.filter({$0.order == self.nextFloorNumArray[index]}).first
        else {
            return
        }
        
        self.changeTile(floorName: nextPlanModel.name)
        
        let group = DispatchGroup()
        group.enter()
        self.didPickFloor(number: Int(nextPlanModel.order)!, dispatchGroup: group)
        
        group.notify(queue: .main) {
            //路線、黃箭頭-朝正上方
            self.arrowAtBegin()
            
            //自動模擬導航
            if self.isAutoSimulate {
                self.startAutoGuide()
            }
            
            //若是 手動/自動 模擬導航，enteredFloorNumber=下一樓層數字，enableTarget=true
            guard (NaviUtility.ManualSimulateMode == true) || (self.isAutoSimulate) else {
                return
            }
            
            self.enteredFloorNumber = self.nextFloorNumArray[index]
            self.simulateEnteredFloorNumber = self.nextFloorNumArray[index]
            self.needDetectTarget = true
        }
    }
    
    func getFloorNumber2(floorNum1: String) -> String? {
        let floorKeys = (self.floorRouteDic.allKeys as! [String])
        
        for i in 0..<floorKeys.count {
            //若同樓層有第二個樓層碼（如:3_1）          //3                     //3_1
            if floorKeys[i].count > 2 && floorNum1.first == floorKeys[i].first {
                let floorNumber2 = floorKeys[i]
                return floorNumber2
            }
        }
        return nil
    }
    
    // 顯示路線
    func showPolyLine(floorNumber: String, completion: ((GMSMutablePath?) -> Void)?) {
        //檢查是否有路徑資料
        guard self.floorRouteDic.count > 0 else {
            return completion!(nil)
        }
        
        // 清除路線
        self.path1.removeAllCoordinates()
        self.polyline1.map = nil
        self.backgroundPath1.map = nil

        self.path2.removeAllCoordinates()
        self.polyline2.map = nil

        //第一條路線
        guard let route1Array = self.getRoute1Array(floorNumber: floorNumber) else {
            return completion!(nil)
        }

        var focusedPath: GMSMutablePath!
        
        self.path1 = NaviUtility.getPath(floorRouteArray: route1Array)
        self.polyline1 = NaviUtility.getPolyLine(path: self.path1, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), width: 7)
        self.polyline1.map = self.mapView
        self.polyline1.zIndex = 2
        self.backgroundPath1 = NaviUtility.getPolyLine(path: self.path1, color: #colorLiteral(red: 0, green: 0.4431372549, blue: 0.7137254902, alpha: 1), width: 9)
        self.backgroundPath1.map = self.mapView
        self.backgroundPath1.zIndex = 1
        
        //填滿路線的方向Markers
        let directionCoordinates = NaviUtility.GetSimulateCoordinates(focusedPath: self.path1)
        self.directionMarkersList = DirectionMarkersListModel(coordinates: directionCoordinates)

        //若有第二條路線，例:floorKeys=["3", "3_1", "1", "-1", "2"]，其中"3_1" -> count=3
        guard let route2Array = self.getRoute2Array(floorNumber: floorNumber) else {
            focusedPath = self.path1
            completion!(focusedPath)
            return
        }
        self.path2 = NaviUtility.getPath(floorRouteArray: route2Array)
        self.polyline2 = NaviUtility.getPolyLine(path: self.path2, color: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), width: 5)
        self.polyline2.map = self.mapView

        //找出要使用的路線（離用戶較近）
        focusedPath = NaviUtility.getFocusedPath(path1: self.path1,
                                                   path2: self.path2,
                                                   userCoordinate: self.userCoordinate)
        completion!(focusedPath)
    }
    
    func getRoute1Array(floorNumber: String) -> [[String: Double]]? {
        guard
            let route1Array = self.floorRouteDic[floorNumber] as? [[String: Double]]
        else {
            return nil
        }
        return route1Array
    }
    
    func getRoute2Array(floorNumber: String) -> [[String: Double]]? {
        guard
            let floorNumber2 = self.getFloorNumber2(floorNum1: floorNumber),
            let route2Array = self.floorRouteDic[floorNumber2] as? [[String: Double]]
        else {
            return nil
        }
        return route2Array
    }
        
    //箭頭標在線段起點
    func arrowAtBegin() {
        if let enteredPlanId = self.enteredPlanId {
            self.pickedPlanId = enteredPlanId
        }
        
        self.arrowMarker.rotation = 0

        guard self.focusedPath != nil else {
            return
        }
        
        let xx = self.focusedPath.coordinate(at: 0).longitude
        let yy = self.focusedPath.coordinate(at: 0).latitude
        
        // 螢幕旋轉角度
        let line1Bearing = NaviUtility.GetBearingBetweenTwoPoints(point1: self.focusedPath.coordinate(at: 0), point2: self.focusedPath.coordinate(at: 1))
        let camera = GMSCameraPosition.camera(withLatitude: yy, longitude: xx, zoom: self.isNavigating ? (self.locateZoom) : (self.locateZoom - 1), bearing: line1Bearing, viewingAngle: 0)
        // 產生箭頭、方位角
        DispatchQueue.main.async(execute: {
            self.mapView.animate(to: camera)

            self.arrowMarker.position = CLLocationCoordinate2DMake(yy, xx)
            self.arrowMarker.map = self.mapView
            self.arrowPosition = CLLocation(latitude: yy, longitude: xx)
            self.showArrow = true
            
            if self.userDirection == nil {
                return
            }
            
            //箭頭方向與線段方向一樣
            self.arrowMarker.rotation = -self.userDirection + line1Bearing
            
            self.cameraState = .fixNorth
            self.changeLocateBtnState(cameraState: .fixNorth)
        })
    }
    
    func determineArrowMarker(at position: CLLocation) {
        guard self.arrowPosition != nil else {
            return
        }
        
        //兩次箭頭距離大於指定數值，不更新箭頭
        if position.distance(from: self.arrowPosition) > Paras.arrowDistance {
            //不更新箭頭
            self.showArrow = false
            
            //計數+1
            self.arrowPendingTime += 1
            
            //計數達到5，arrowPosition = projectedPosition
            if self.arrowPendingTime >= Paras.arrowPendingLimit {
                self.arrowPendingTime = 0
                self.arrowPosition = position
                self.showArrow = true
            }
        }else { //兩次箭頭距離正常，更新箭頭
            self.arrowPosition = position
            self.showArrow = true
            self.arrowPendingTime = 0
        }

        //更新箭頭
        if self.showArrow {
            self.refreshArrowMarker(position: position)
        }

        //計算「箭頭」與「標的」距離
        if self.showArrow && self.needDetectTarget {
            self.needDetectTarget = false
            self.updateTargetDistance(arrowLoc: position)
        }
    }
    
    func refreshArrowMarker(position: CLLocation) {
        // 線段方位角
        self.line1Bearing = NaviUtility.GetBearingBetweenTwoPoints(point1: self.focusedPath.coordinate(at: self.segmentBeginIndex), point2: self.focusedPath.coordinate(at: self.segmentBeginIndex + 1))
        self.arrowMarker.position = CLLocationCoordinate2DMake(position.coordinate.latitude, position.coordinate.longitude)
        DispatchQueue.main.async {
            // 箭頭位置
            self.arrowMarker.map = self.mapView
        }
    }
    
    func updateDirectionLab(segmentBeginIndex: UInt, projectedPosition: CLLocation) {
        //箭頭到下一點的距離
        let nextPointLat = self.focusedPath.coordinate(at: segmentBeginIndex + UInt(1)).latitude
        let nextPointLng = self.focusedPath.coordinate(at: segmentBeginIndex + UInt(1)).longitude
        let nextPoint = CLLocation(latitude: nextPointLat, longitude: nextPointLng)
        let nextPointDistance = Double(nextPoint.distance(from: projectedPosition)) //距離(公尺)，取到整數
        
        guard let nodeAngle = self.getNodeAngle() else {
            return
        }
        
        var angle = nodeAngle
        
        //處理小於-180、大於+180
        if angle < -180.0 {
            angle = angle + 360.0
        }
        if angle > 180.0 {
            angle = angle - 360.0
        }
        
        //依據「轉彎角度」加入提示文字
        var direction: NavPoint.Direction!
        if angle >= 45.0 {
            direction = .right
        }else if angle <= -45.0 {
            direction = .left
        }else if angle >= 10.0 && angle < 45.0 {
            direction = .slightRight
        }else if angle <= -10.0 && angle > -45.0 {
            direction = .slightLeft
        }else {
            direction = .alongStraight
        }
        
        //將抵達路線末端點
        if segmentBeginIndex + UInt(2) == self.focusedPath.count() {
            direction = .alongStraight
        }

        //更新導引指示文字
        self.navGuideVC.update(distance: nextPointDistance, and: direction)
    }
    
    func getNodeAngle() -> Double? {
        guard
            let line1Bearing = self.getLine1bearing(),
            let line2Bearing = self.getLine2bearing()
        else {
            return nil
        }
        return line2Bearing - line1Bearing
    }
    
    //計算目標距離
    func updateTargetDistance(arrowLoc: CLLocation) {
        guard !(self.endCoordinateArray.isEmpty) else {
            return
        }

        let enteredFloorNumber = self.filterEnteredFloorNumber(self.isAutoSimulate)

        //依據使用者目前樓層，找出對應的floorNum，再找出askIndex
        for i in 0..<self.nextFloorNumArray.count {
            if enteredFloorNumber == self.nextFloorNumArray[i] {
                self.askIndex = i
            }
        }
        
        // 判斷「抵達目的地」或「前往下個樓層」
        let reachType = self.getReachType()

        switch reachType {
        case .End:
            //最後終點距離(公尺)
            let distance = self.endLocation!.distance(from: arrowLoc)
            self.determineReachEnd(by: distance, arrowLoc: arrowLoc)
        case .NextFloor:
            //目前樓層標的距離
            let distance = self.endCoordinateArray[self.askIndex].distance(from: arrowLoc)

            if distance < Paras.guideDistance {
                //鎖定要前往的下個樓 - 依據「下個樓層」的路徑節點數
                let nextFloor = self.getNextFloor()
                self.lockedNextPlanID = nextFloor[2] as! String
                self.popReachedMessage(reachtType: .NextFloor, nextFloor: nextFloor)
                
                DispatchQueue.main.async {
                    self.needDetectTarget = false
                }
            }else {
                DispatchQueue.main.async {
                    self.needDetectTarget = true
                }
            }
        }
    }
    
    func determineReachEnd(by distance: CLLocationDistance, arrowLoc: CLLocation) {
        let arrowToEndDistance = self.endCoordinateArray[self.askIndex].distance(from: arrowLoc)
        
        //已抵達目的地
        if arrowToEndDistance < Paras.guideDistance {
            self.popReachedMessage(reachtType: .End, nextFloor: [])
            self.isAutoSimulate = nil
        }else {
            self.needDetectTarget = true
        }
    }
    
    func getReachType() -> ReachType {
        let enteredFloorNumber = self.filterEnteredFloorNumber(self.isAutoSimulate)
        
        if (self.endLocation != nil), (enteredFloorNumber == self.endFloorNum) {
            return ReachType.End
        }else {
            return ReachType.NextFloor
        }
    }
    
    func filterEnteredFloorNumber(_ isAutoSimulate: Bool?) -> String {
        return (isAutoSimulate == true) ? self.simulateEnteredFloorNumber : self.enteredFloorNumber
    }
    
    func navPresenter(didUpdate cameraState: CameraState) {
        self.cameraState = cameraState
        
        switch cameraState {
        case .flexible:
            locateBtn.setImage(UIImage(named: "map_unlocate", in: Bundle(for: MapVC.self), compatibleWith: nil), for: .normal)
        case .fixUser:
            locateBtn.setImage(UIImage(named: "map_locate", in: Bundle(for: MapVC.self), compatibleWith: nil), for: .normal)
        case .fixNorth:
            locateBtn.setImage(UIImage(named: "map_fixNorth", in: Bundle(for: MapVC.self), compatibleWith: nil), for: .normal)
        }
    }

    //MARK: - Navigation Detail Delegate
    func navDetail(didPanned yOffset: CGFloat) {
        let fullHeight = view.frame.height - view.safeAreaInsets.top
        navDetailTop.constant = yOffset < 0 ? fullHeight : 200
        UIView.animate(withDuration: 0.25, animations: {self.view.layoutSubviews()})
    }
    
    func navDetail(didPressedBtnAt index: Int) {
        startSmartGuider()
    }
    
    //MARK: - UI Update
    // Locate Button
    func updateLocateBtn(_ bottomConstant: CGFloat) {
        self.locateBtnBottom.constant = bottomConstant
        UIView.animate(withDuration: 0.25, animations: {self.view.layoutSubviews()})
    }
    
    // Smart Guider
    private func startSmartGuider() {
        self.arrowAtBegin()
        self.navStateView.isHidden = (NaviProject.isTaipeiProject == true) ? true:false
        self.navStateView.navBtnStart()
        self.cameraState = .fixNorth
        
        //改變定位按鈕圖案
        self.changeLocateBtnState(cameraState: self.cameraState)
        
        self.navPresenter.startSmartGuider()
        
        self.navGuideVC.updateToInfo()
        self.navGuideBottom.constant = self.navGuideVC.infoView.frame.height
        mapNavigationDelegate?.mapDidStartSmartGuider()
    }
    
    private func changeLocateBtnState(cameraState: CameraState) {
        switch cameraState {
        case .flexible:
            locateBtn.setImage(UIImage(named: "map_unlocate", in: Bundle(for: MapVC.self), compatibleWith: nil), for: .normal)
            
        case .fixUser:
            locateBtn.setImage(UIImage(named: "map_locate", in: Bundle(for: MapVC.self), compatibleWith: nil), for: .normal)
            
        case .fixNorth:
            guard self.isNavigating else {
                return
            }
            locateBtn.setImage(UIImage(named: "map_fixNorth", in: Bundle(for: MapVC.self), compatibleWith: nil), for: .normal)
        }
    }
    
    private func endSmartGuider() {
        self.arrowMarker.map = nil

        self.navStateView.isHidden = true
        self.navStateView.navBtnEnd()
        
        let group = DispatchGroup()
        group.enter()
        self.navGuideVC.updateToTraffic(dispatchGroup: group)
        group.notify(queue: .main) {
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .linear, animations: {
                self.navGuideBottom.constant = self.navGuideVC.trafficViewHeight.constant
                self.view.layoutIfNeeded()
            })
            animator.startAnimation()
            self.setNavBottomGuideHidden(false)
        }
        
        mapNavigationDelegate?.mapDidEndSmartGuider()
        
        self.navPresenter.endSmartGuider()
    }
    
    // Choose Mode
    private func setChooseModeViews(_ isHidden: Bool) {
        chooseBtn.isHidden = isHidden
        chooseImageView.isHidden = isHidden
        locateBtn.isHidden = !isHidden
    }
    
    //MARK: - Initialization
    private func setupMapView() {
        self.pinchedZoom = Paras.initZoom

        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle(for: MapVC.self).url(forResource: "mapStyle", withExtension: "json", subdirectory: "MapStyle") {
                self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            }else {
                print("Unable to find style.json")
            }
        }catch {
            print("One or more of the map styles failed to load. \(error)")
        }

        self.mapView.isBuildingsEnabled = false
        self.mapView.frame = view.bounds
        self.mapView.delegate = self
        
        //用於clusters
        self.mapView.dataSource = self
        
        self.mapView.setMinZoom(14, maxZoom: 21)
        self.view.insertSubview(self.mapView, at: 0)
        
        // Navigation
        self.setNavViewsShowing(false,false)
        
        // Choose Mode
        self.chooseBtn.setTitle("選擇位置", for: .normal)
        self.chooseBtn.layer.cornerRadius = 20
        
        self.setupUserMarker()
        self.setupArrowMarker()
    }
    
    func moveToDefaultPlan() {
        //朋友模式
        if self.markerMode == .WatchFriend {
            return
        }

        //一般模式
        self.moveTo(location: NaviProject.usedProjectModel.defaultPlanLocation,
                    zoom: self.planBoundZoom)
        self.didPickFloor(number: Int(self.enteredFloorNumber)!, dispatchGroup: nil)
    }

    func showMarkers(mode: MarkerMode, planId: String) {
        print("showMarkers(mode=\(mode)")
        switch mode {
        //一般、選擇集合點、顯示集合點
        case .Default, .PickGatherPoint, .GoGatherPoint:
            self.showMarkers(by: planId, ac_id: self.current_ac_id, aac_id: self.current_aac_id, aac_ids: self.current_aac_id_array)
        default:
            print("")
        }
    }
            
    func showGatherPoiOnce() {
        if (self.markerMode == .GoGatherPoint), (self.hasShowGatherPoiOnce == false) {
            self.hasShowGatherPoiOnce = true
        }
    }
    
    func moveTo(location: CLLocation?, zoom: Float) {
        guard let loc = location else {
            return
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, zoom: self.isNavigating ? zoom : (zoom - 1))
        DispatchQueue.main.async(execute: {
            self.mapView.animate(to: camera)
        })
    }
    
    func zoomToMax(completion: @escaping (() -> Void)) {
        let camera = GMSCameraPosition.camera(withTarget: self.currentCameraCoordinate, zoom: 22)
        
        DispatchQueue.main.async(execute: {
            self.mapView.animate(to: camera)
        })
        
        let seconds = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    func showTile(planId: String?) {
        guard let planId = planId else {
            return
        }
        
        self.pickedPlanId = self.planModels.filter({$0.plan_id == planId}).first?.plan_id
        self.loadTile(planId: planId)
    }
    
    func changeMapMode(_ type: MapModeType) -> Bool {
        guard let planId = pickedPlanId else {
            return false
        }
        currentMapMode = type
        loadTile(planId: planId)
        return true
    }
    
    func loadTile(planId: String) {
        let urls = { (x: UInt, y: UInt, zoom: UInt) -> URL in
            let url = "https://omnig-anyplace.omniguider.com/map/tile/\(planId)/\(zoom)/\(x)/\(y).png"
            return URL(string: url)!
        }
        
        self.tileLayer?.map = nil
        self.tileLayer = GMSURLTileLayer(urlConstructor: urls)
        self.tileLayer?.map = self.mapView
        self.tileLayer?.setOpacity(self.isNavigating)
        
        //marker mode
        self.showMarkers(mode: self.markerMode, planId: planId)
    }
    
    func startSimulateGuide() {
        self.simulateEnteredFloorNumber = String(self.routeStartFloorNumber)
        
        let group = DispatchGroup()
        group.enter()
        
        group.notify(queue: .main) {
            self.startSmartGuider()
            self.setIsNavigating()
            self.startAutoGuide()
        }
        //切換到起點樓層
        self.didPickFloor(number: self.routeStartFloorNumber,
                            dispatchGroup: group)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "navGuide":
            self.navGuideVC = (segue.destination as! NavigationGuideVC)
            self.navGuideVC.delegate = self
        case "navSearch":
            self.navSearchVC = (segue.destination as! NavigationMapSearchVC)
            self.navSearchVC.delegate = self
        case "NavBottomGuideSegue":
            navBottomGuideVC = (segue.destination as! NavigationBottomGuideVC)
            navBottomGuideVC.delegate = self
        default:
            break
        }
    }
    
    func newRouteOfBegin(_ point: OGPointModel?, _ coordinate: CLLocationCoordinate2D?, _ navType: NavigationPresenter.NavigationType) {
        var beginCoordinate = coordinate
        self.navBeginFloorNumber = (navType == .userLocation) ? self.enteredFloorNumber : self.pickedFloorNumber

        if beginCoordinate == nil {
            guard let poiModel = point else {
                return
            }

            beginCoordinate = NaviUtility.GetCoordinate(from: poiModel)
            self.navBeginFloorNumber = String(poiModel.number)
        }
        
        self.clearRouteData()
        let group = DispatchGroup()
        group.enter()
        self.routeApiType = .coordinateToPoint
        
        self.navPresenter.getNaviRouteXyAPI(from: self.navBeginFloorNumber, beginCoordinate: beginCoordinate!, priority: self.priority.rawValue, endPoint: GlobalState.endPoi, dispatchGroup: group)
        group.notify(queue: .main) {
            self.navPresenter.renewInfo(point, beginCoordinate, type: navType)
        }

        endSearchMode()
    }
}

//MARK: - Navigation Presenter Delegate
extension MapVC: NavigationPresenterDelegate {
    func navPresenter(didLoad routeArray: [[String : Any]]) {
        self.normalRoute = routeArray
        self.reversedRoute = NaviUtility.GetReversedRoute(route: routeArray)
        
        DispatchQueue.main.async {
            self.prepareRoute(routeArray: self.getShowedRoute(mode: self.routeOrderMode) )
            
            // UI Update
            self.setNavViewsShowing(true)
            self.updateLocateBtn(114 + 16)
            self.mapNavigationDelegate?.mapDidStartNavigation()
            self.navStateView.setup(poiModel: self.targetPoint)
            self.mapView.padding.top = Paras.mapTopPadding
        }
    }
    
    func navPresenter(didUpdate title: String, pressedBtnType: NavigationPresenter.PressedBtnType, navigationType: NavigationPresenter.NavigationType) {
        self.navGuideVC.updateTrafficVCBtnInfo(with: title, pressedBtnType: pressedBtnType, navigationType: navigationType)
    }
    
    func navPresenter(didUpdateBtnTitle currentTitle: String, targetPoiModel: OGPointModel) {
        self.navGuideVC.didUpdateBtnTitle(to: currentTitle, targetPoiModel: targetPoiModel)
    }
    
    func navPresenter(showNearbyPoi poi: OGPointModel) {
        
    }
}


//MARK: Navigation Guide Delegate
extension MapVC: NavigationGuideDelegate {
    func navGuide(didPressedSwitchBtn routeMode: RouteOrderMode) {
        self.routeOrderMode = routeMode
        self.prepareRoute(routeArray: self.getShowedRoute(mode: routeOrderMode))
    }
    
    func navGuideStartSearchVC(with pressedBtnType: NavigationPresenter.PressedBtnType, _ displayUserLocation: Bool) {
        startSearchMode(displayUserLocation)
        self.navPresenter.didPositionBtnPressed(with: pressedBtnType)
    }
    
    func guideTrafficDidPressSimulateBtn() {
        self.startSimulateGuide()
    }
    
    func guideTrafficDidPressNavBtn() {
        self.startGuide()
    }
    
    func guideTrafficDidChoosePriority(tag: Int) {
        self.priority = (tag == 1) ? .elevator : .normal
        
        if self.focusedPath == nil {
            return
        }
        
        self.changeRoutePriority(routeApiType: self.routeApiType)
    }
    
    func startGuide() {
        let group = DispatchGroup()
        group.enter()
        
        group.notify(queue: .main) {
            self.startSmartGuider()
            self.setIsNavigating()
        }
        //切換到起點樓層
        self.didPickFloor(number: self.routeStartFloorNumber, dispatchGroup: group)
    }
}

//MARK: - Navigation Search Delegate
extension MapVC: NavigationSearchDelegate {
    func navSearchDidSelect(_ point: OGPointModel?,  _ coordinate: CLLocationCoordinate2D?, type: NavigationPresenter.NavigationType) {
        self.newRouteOfBegin(point, coordinate, type)
    }
    
    func navSearchDidStartChooseMode() {
        mapNavigationDelegate?.mapDidStartChooseMode()
        navSearchHeight.constant = 0
        setNavViewsShowing(false)
        updateLocateBtn(16)
        setChooseModeViews(false)
    }
}

extension MapVC: NavigationStateDelegate {
    //MARK: - Navigation State Delegate
    func navStateDidPressStart() {
    }

    func navStateDidPressSimulate() {
    }

    func navStateDidPressEnd() {
        self.isNavigating = false
        self.showArrow = false
        self.userMarker.map = self.mapView
        self.isAutoSimulate = nil
        self.endSmartGuider()
        self.stopAutoGuide()
        self.tileLayer?.setOpacity(self.isNavigating)
    }
    
    //開始模擬導航
    func startAutoGuide() {
        self.isAutoSimulate = true

        //該樓層預計要走的座標點
        self.simulateCoordinates = NaviUtility.GetSimulateCoordinates(focusedPath: self.focusedPath)
        
        //定時移動
        self.autoGuideTimer = Timer.scheduledTimer(withTimeInterval: Paras.stepTime, repeats: true, block: {timer in

            //停止模擬導航
            if self.needStopAutoGuide {
                self.stopAutoGuide()
                return
            }
            
            //每n秒鐘移動一次
            NaviUtility.CaculateArrowData(userCoordinate: self.simulateCoordinates[self.autoCount], focusedPath: self.focusedPath, completion: {position, distance, beginIndex in
                self.didRefreshArrow(position, distance, beginIndex)
                self.autoCount += 1
                
                //路線朝正上方
                guard let line1Bearing = self.getLine1bearing() else {
                    return
                }
                self.rotateMap(heading: line1Bearing)
            })
        })
    }
    
    var needStopAutoGuide: Bool {
        if (self.isAutoSimulate == nil) || (self.autoCount >= self.simulateCoordinates.count) {
            return true
        }else {
            return false
        }
    }
    
    //停止模擬導航
    func stopAutoGuide() {
        if self.autoGuideTimer != nil {
            self.autoGuideTimer.invalidate()
        }
        self.autoCount = 0
    }
}

extension MapVC: LocationBaseDelegate, UIGestureRecognizerDelegate {
    func locationInfo(didUpdate loc: CLLocation) {
        if NaviUtility.ManualSimulateMode {
            return
        }

        self.userCoordinate = loc.coordinate
        self.userMarker.position = loc.coordinate
        self.userMarker.recordPosition()
        self.determineRefreshArrow()
    }

    func locationInfo(didEnter identifier: String) {
        self.updateEnteredPlan(regionId: identifier)
    }
    
    func locationInfo(didUpdate direction: CLLocationDirection) {
        self.userDirection = direction
        self.userMarker.rotation = self.userDirection - self.mapView.camera.bearing
        
        //模擬導航中-停止手機方向旋轉地圖
        if self.isAutoSimulate == true {
            return
        }
        
        //地圖旋轉機制
        self.rotateMap(heading: self.userDirection)
    }
    
    func getLine1bearing() -> Double? {
        guard self.segmentBeginIndex != nil else {
            return nil
        }
        
        let line1Bearing = NaviUtility.GetBearingBetweenTwoPoints(point1: self.focusedPath.coordinate(at: self.segmentBeginIndex), point2: self.focusedPath.coordinate(at: self.segmentBeginIndex + UInt(1)))
        return line1Bearing
    }
    
    func getLine2bearing() -> Double? {
        guard self.segmentBeginIndex != nil else {
            return nil
        }

        let line2Bearing = NaviUtility.GetBearingBetweenTwoPoints(point1: self.focusedPath.coordinate(at: self.segmentBeginIndex + UInt(1)), point2: self.focusedPath.coordinate(at: self.segmentBeginIndex + UInt(2)))
        return line2Bearing
    }
    
    func determineDeviation(nearestDistance: Double?) {
        guard isNavigating else {
            return
        }
        
        if nearestDistance != nil && nearestDistance! * 100000 > Paras.offsetDistance && self.isRecaculateRoute == "no" {
            self.isRecaculateRoute = "yes"
            
            DispatchQueue.main.async {
                self.deviationTimer = Timer.scheduledTimer(timeInterval: Paras.offsetTime, target: self, selector: #selector(self.checkDeviation), userInfo: nil, repeats: false)
            }
        }
    }
    
    //x秒後檢查是否偏離路線，若是，重新規劃路線
    @objc func checkDeviation() {
        if self.nearestDistance != nil, self.nearestDistance! * 100000 > Paras.offsetDistance, self.isRecaculateRoute == "yes" {
            //提示
            self.popRerouteAlert()
        }else {
            print("不需重新計算路線")
            self.isRecaculateRoute = "no" //回復預設
        }
    }
    
    func popRerouteAlert() {
        let alert = UIAlertController(title: Paras.offsetMsg, message: nil, preferredStyle: .alert)
        let act1 = UIAlertAction(title: "好", style: .default, handler: {action in
            print("重新計算路線")
            self.changeRoutePriority(routeApiType: self.routeApiType)
            self.isRecaculateRoute = "no"
        })
        let act2 = UIAlertAction(title: "不用", style: .cancel, handler: {action in
            print("不用重新計算路線")
            self.isRecaculateRoute = "no"
        })
        alert.addAction(act2)
        alert.addAction(act1)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func changeRoutePriority(routeApiType: RouteApiType) {
        self.clearRouteData()
        
        if routeApiType == .coordinateToPoint {
            if let userCoordinate {
                self.getRoute(apiType: routeApiType, from: userCoordinate, to: GlobalState.endPoi)
            }
        }
        
        if routeApiType == .pointToPoint {
            self.getRoute(apiType: routeApiType, from: NaviProject.usedProjectModel.defaultBeginPoiId, to: GlobalState.endPoi)
        }
    }

    func rotateMap(heading: CLLocationDirection) {
        //導航時
        guard
            self.isNavigating,
            self.userCoordinate != nil
        else {
            return
        }
        
        switch self.cameraState {
            //地圖、路徑、箭頭，一起轉（用於判斷手機方向是否與箭頭方向一致）
            case .fixNorth:
                let lat = self.arrowMarker.position.latitude
                let lng = self.arrowMarker.position.longitude
                
                //camera移動、旋轉
                let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: self.isNavigating ? 20 : self.pinchedZoom, bearing: heading, viewingAngle: 0)
                DispatchQueue.main.async(execute: {
                    self.mapView.camera = camera

                    guard let line1Bearing = self.getLine1bearing() else {
                        return
                    }
                    
                    if self.isAutoSimulate {
                        self.arrowMarker.rotation = 0
                    }else {
                        //箭頭方向與線段方向一樣
                        self.arrowMarker.rotation = -heading + line1Bearing
                    }
                })
            //只有箭頭轉
            case .fixUser:
                if (self.userDirection == nil) {
                    return
                }
                self.arrowMarker.rotation = self.userDirection - self.mapView.camera.bearing
                self.mapView.animate(toBearing: 0)
            default:
                break
        }
    }
    
    func updateEnteredPlan(regionId: String) {
        print("updateEnteredPlan")
        self.enteredPlanId = regionId
        self.pickedPlanId = regionId
        self.enteredFloorName = NaviUtility.GetFloorName(by: regionId)
        self.enteredFloorNumber = NaviUtility.GetFloorNumber(by: regionId) ?? "1"
        self.navBeginFloorNumber = NaviUtility.GetFloorNumber(by: regionId) ?? "1"
        self.refreshFloor(regionId: regionId)
        self.moveToUser()
    }
    
    func refreshFloor(regionId: String) {
        self.floorBtn.setTitle(self.enteredFloorName, for: .normal)
        self.showTile(planId: regionId)
                        
        let group = DispatchGroup()
        group.enter()
        self.didPickFloor(number: Int(self.enteredFloorNumber)!, dispatchGroup: group)
        
        group.notify(queue: .main) {
            //路線、黃箭頭-朝正上方
            self.arrowAtBegin()
            
            //自動模擬導航
            if self.isAutoSimulate {
                self.startAutoGuide()
            }
            
            //若是 手動/自動 模擬導航，enteredFloorNumber=下一樓層數字，enableTarget=true
            guard NaviUtility.ManualSimulateMode || self.isAutoSimulate else {
                return
            }

            //開啟計算距離
            self.needDetectTarget = true
        }
    }
    
    @objc func prepare() {
        self.planModels = NaviProject.planModels
        self.locateZoom = NaviProject.usedProjectModel.locateZoom
        self.planBoundZoom = NaviProject.usedProjectModel.planBoundZoom
        self.pickedPlanId = self.planModels[NaviProject.usedProjectModel.defaultPlanIndex].plan_id
        self.prepareLocationBase()
        self.moveToDefaultPlan()
    }
    
    private func prepareLocationBase() {
        LocationBase.shared.delegate = self
        NaviUtility.CheckUserLocationReady(complement: {
            self.determineDidEnterNow()
        })
    }

    private func determineDidEnterNow() {
        if NaviUtility.ManualSimulateMode {
            self.enteredFloorNumber = GlobalState.tappedFloorNumber
            
            if let enteredPlanId = GlobalState.tappedPlanId {
                self.enteredPlanId = enteredPlanId
                self.pickedPlanId = enteredPlanId
                self.locationInfo(didEnter: enteredPlanId)
            }
            return
        }
        
        guard let enteredPlanId = LocationBase.shared.enteredProjectPlanId else {
            return
        }
        self.locationInfo(didEnter: enteredPlanId)
    }

    private func showMarkers(by planId: String?, ac_id: Int?, aac_id: Int, aac_ids: [Int]) {
        //清空marker、markerAnnotations
        self.markerAnnotations.removeAll()
        self.mapView.clusterManager.annotations.removeAll()
        
        var poiModels: [OGPointModel] = []
        
        //判斷導航中只顯示：起點/終點
        if self.beginPoiModel != nil {
            poiModels = NaviUtility.GetPoiModelsBy(planId: planId, begin: self.beginPoiModel, end: self.endPoiModel)
        }else {
            for value in aac_ids {
                poiModels += NaviUtility.RetrievePoiModels(by: planId, ac_id: ac_id, aac_id: value, planModels: self.planModels)
            }
        }

        NaviProject.presentedPoiModels = poiModels
        
        //產生markerAnnotations
        poiModels.forEach({
            self.markerAnnotations.append(self.getAnnotation(poiModel: $0))
        })
        
        //清除showedMarkers
        self.showedMarkers.removeAll()

        //顯示marker、cluster
        self.mapView.clusterManager.annotations = self.markerAnnotations
        
        self.showGatherPoiOnce()
    }
    
    private func showDirectionMarkers(markers: [GMSMarker]) {
        markers.forEach({
            $0.map = self.mapView
        })
    }
    
    //偵測所有元件的手勢
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        self.cameraState = .flexible
        self.changeLocateBtnState(cameraState: .flexible)
        return true
    }
}

extension MapVC: GMSMapViewDelegate, GMSMapViewDataSource {
    // 顯示興趣點，依類別
    func getAnnotation(poiModel: OGPointModel) -> GMSMarkerAnnotation {
        let annotation = GMSMarkerAnnotation()
        annotation.coordinate = CLLocation(latitude: poiModel.lat,longitude: poiModel.lng).coordinate
        annotation.title = String(poiModel.id)
        annotation.poiId = poiModel.id
        annotation.name = poiModel.name
        annotation.ac_id = poiModel.ac_id
        return annotation
    }
    
    // 點按「標記」(興趣點)
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.showFloorContainer(show: false)

        guard let cluster = marker.cluster else {
            return false
        }
        
        if cluster.count > 1 {
            let padding = UIEdgeInsets(top: 40, left: 20, bottom: 44, right: 20)
            let cameraUpdate = GMSCameraUpdate.fit(cluster, with: padding)
            mapView.animate(with: cameraUpdate)
            mapView.animate(toBearing: 237.3)
            return true
        }

        //集合點
        if self.markerMode == .PickGatherPoint {
            self.changGather(marker: marker)
            return false
        }

        // 未導航才會有回應，且「不是文字marker」
        if self.isNavigating == false {
            //當點擊POI才出現資訊板(zIndex小於1000)
            if marker.zIndex < 1000
            {
                self.mapDelegate?.map(didSelect: marker)
            }
            //重新顯示marker
            self.tapMarkerRefresh(marker: marker)
        }
        
        return true
    }
    
    
    // 點按「地圖任一處，非標記」
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.showFloorContainer(show: false)
        
        //模擬位置
        if NaviUtility.ManualSimulateMode {
            self.setManualLocation(coordinate)
        }
        
        if self.isNavigating {
            return
        }
        
        //重新顯示marker
        self.tapMapRefresh()
    }
    
    func setManualLocation(_ coordinate: CLLocationCoordinate2D) {
        self.userCoordinate = coordinate
        self.userMarker.position = coordinate
        self.tapMove(coordinate: coordinate)
        
        self.enteredFloorNumber = self.pickedFloorNumber
        self.navBeginFloorNumber = self.pickedFloorNumber
        self.enteredPlanId = NaviUtility.GetPlanId(by: Int(self.enteredFloorNumber)!)
        self.pickedPlanId = self.enteredPlanId
        
        GlobalState.tappedCoordinate = coordinate
        GlobalState.tappedPlanId = self.pickedPlanId
        GlobalState.tappedFloorNumber = self.enteredFloorNumber
    }
    
    func tapMove(coordinate: CLLocationCoordinate2D) {
        guard self.focusedPath != nil else {
            return
        }
        
        self.userCoordinate = coordinate

        NaviUtility.CaculateArrowData(userCoordinate: coordinate, focusedPath: self.focusedPath, completion: {position, distance, beginIndex in
            self.didRefreshArrow(position, distance, beginIndex)
        })
    }
    
    func tapMapRefresh() {
        self.showMarkers(by: self.pickedPlanId, ac_id: self.current_ac_id, aac_id: self.current_aac_id, aac_ids: self.current_aac_id_array)
        self.mapDelegate?.mapDidTapAtCoordinate()
    }
    
    func tapMarkerRefresh(marker: GMSMarker) {
        //< 處理「點擊地圖marker產生動畫icon」及「恢復marker icon」
        // 上一個marker icon圖案復原
        DispatchQueue.main.async {
            if self.lastMarker != nil {
                //將「原來的圖案」放回上一個marker(selectedMarker)
                self.lastMarker.icon = self.originalIcon
            }
        }
        
        // 下一個marker icon圖案動畫
        DispatchQueue.main.async {
            self.originalIcon = marker.icon! //儲存「原來marker的圖案」
            self.lastMarker = marker //儲存「原來的marker」
            marker.appearAnimation = GMSMarkerAnimation.pop //可以彈出動畫
            
            //換圖案
            if let poi = NaviUtility.GetPoiModel(by: marker) {
                marker.icon = UIImage().poiTypeToImage(ac_id: poi.ac_id, isSelected: true, bundle: Bundle(for: MapVC.self))
            }else {
                marker.icon = NAVIAsset.icon_select.img
            }
            marker.zIndex += self.zindexN //確保「下一個marker」不會被其他marker擋到
            self.zindexN += 1 //最新的動畫圖案位置最高
            marker.map = nil //先做這個，在做下個，才會有動畫
            marker.map = self.mapView
        }
        // >
                
        // <篩選marker
        for i in 0..<NaviProject.presentedPoiModels.count {
            if marker.userData as? Int == NaviProject.presentedPoiModels[i].id {
                self.tappedPoiId = String(NaviProject.presentedPoiModels[i].id)
                self.hasTappedPoi = true
            }
        }
        // >
    }

    func mapView(_ mapView: GMSMapView, markerFor cluster: CKCluster) -> GMSMarker {
        let marker = GMSMarker(position: cluster.coordinate)
        
        //若cluster數量大於1，顯示數字marker
        if cluster.count > 1 {
            let clusterNum = "\(cluster.count)"
            if let image = UIImage(named: "poi_red", in: Bundle(for: MapVC.self), compatibleWith: nil) {
                marker.icon = UIImage.textWithImage(drawText: clusterNum, inImage: image)
            }
        }else { //顯示正常poi marker
            self.markerAnnotations.forEach({
                if $0.poiId == Int(cluster.title!) {
                    marker.icon = UIImage().poiTypeToImage(ac_id: $0.ac_id, bundle: Bundle(for: MapVC.self))
                    marker.title = $0.name
                    marker.userData = $0.poiId
                    
                    //特定的POI放最上層zIndex
                    if $0.ac_id! >= 10000 {
                        marker.zIndex = 8000
                    }
                    
                    switch $0.ac_id {
                    case 10000:
                        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                        self.beginMarker = marker
                        self.showedMarkers.append(self.beginMarker)
                    case 10001:
                        self.endMarker = marker
                        self.showedMarkers.append(self.endMarker)
                    default:
                        self.showedMarkers.append(marker)
                    }
                }
            })
        }
        
        return marker
    }

    //camera變動時觸發
    public func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.changeDirectionMarkers(cameraPosition: position, cameraZoom: mapView.camera.zoom)
        
        if (self.userDirection == nil) {
            return
        }
        
        //用戶藍點角度（同時考量用戶方位角及地圖旋轉角度）
        self.userMarker.rotation = self.userDirection - self.mapView.camera.bearing
    }
    
    func changeDirectionMarkers(cameraPosition: GMSCameraPosition, cameraZoom: Float) {
        if self.directionMarkersList != nil {
            self.showedDirectionMarkers.forEach({
                $0.map = nil
            })
            self.showedDirectionMarkers = self.directionMarkersList.getDirectionMarkersBy(zoom: cameraZoom)
            self.showDirectionMarkers(markers: self.showedDirectionMarkers)
            
            //旋轉directionMarkers與路線方向一致
            self.currentMapBearing = cameraPosition.bearing
            NaviUtility.RotateDirectionMarkers(mapBearing: self.currentMapBearing, markers: self.showedDirectionMarkers)
        }
    }
    
    //偵測zoom、處理clusters
    public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.currentCameraCoordinate = position.target
        
        //處理zoom
        self.pinchedZoom = self.getZoomLevel()
        
        //處理clusters
        let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
        if mapView.zoom > 18 {
            algorithm.cellSize = 10
        }else {
            algorithm.cellSize = 200
        }
        
        if self.correctIndex == 2 {
            algorithm.cellSize = 0.01
        }
        mapView.clusterManager.algorithm = algorithm
        mapView.clusterManager.updateClustersIfNeeded()
    }
    
    func getZoomLevel() -> Float {
        let zoom = self.mapView.camera.zoom
        print("zoom=\(zoom)")
        return zoom
    }
}

extension MapVC {
    
    @IBAction func pressFloorBtn(_ sender: Any) {
        if self.isAutoSimulate {
            return
        }
        
        let animate = UIViewPropertyAnimator(duration: 0.15, curve: .linear)
        
        animate.addAnimations {
            self.floorMenuVC.reloadFloorNumbers(pickedNumber: Int(self.pickedFloorNumber)!)
            self.showFloorContainer(show: true)
        }
        
        animate.startAnimation()
    }
    
    @objc private func changeFloor(_ floorNumber: Int, completion: @escaping (() -> Void)) {
        let group = DispatchGroup()
        group.enter()

        self.didPickFloor(number: floorNumber, dispatchGroup: group)

        group.notify(queue: .main) {
            completion()
        }
    }
    
    func showUserAndArrowMarker(by floorNumber: String) {
        guard (floorNumber == self.enteredFloorNumber) else {
            self.userMarker.map = nil
            self.arrowMarker.map = nil
            return
        }
        
        self.userMarker.map = (self.isNavigating == false) ? self.mapView : nil
        self.arrowMarker.map = (self.isNavigating == true) ? self.mapView : nil
    }
    
    func determineRefreshArrow() {
        if (self.isNavigating == true), (self.pickedPlanId == self.enteredPlanId) {
            NaviUtility.CaculateArrowData(userCoordinate: self.userCoordinate, focusedPath: self.focusedPath, completion: {position, distance, beginIndex in
                self.didRefreshArrow(position, distance, beginIndex)
            })
        }
    }
    
    func didRefreshArrow(_ position: CLLocation?, _ distance: Double?, _ segmentBeginIndex: UInt?) {
        if position == nil {
            return
        }
        
        //判斷更新箭頭 - 檢查「新投影位置(後)與箭頭位置(前)的距離」
        self.determineArrowMarker(at: position!)
        
        //檢查偏離路徑-重新規劃路線
        self.determineDeviation(nearestDistance: distance)
        
        //指引：左轉、右轉、沿路線行走、箭頭與下一個節點距離
        self.segmentBeginIndex = segmentBeginIndex
        self.updateDirectionLab(segmentBeginIndex: self.segmentBeginIndex,
                                projectedPosition: position!)
        //記錄偏差值
    }
    
    func changeTile(floorName: String) {
        currentFloor = NaviUtility.GetFloorNumber(at: floorName)
        self.showTile(planId: NaviUtility.GetPlanId(by: currentFloor))
    }
    
    private func createCategoryBtn(_ title: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.1
        btn.setTitleColor(#colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1), for: .normal)
        btn.backgroundColor = .white
        btn.layer.addShadow()
        return btn
    }

    private func setupAacCategoryButtons() {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        self.aacCategoryView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: self.aacCategoryView.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.aacCategoryView.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.aacCategoryView.leadingAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.aacCategoryView.trailingAnchor, constant: 0).isActive = true
        
        var maxX: CGFloat = 24
        var aacCategoryModels = NaviProject.aacCategoryModels
        
        let aacCategory_allType = AacCategoryModel(data: ["aac_id":0,
                                                          "category":"全部"])
        aacCategoryModels.insert(aacCategory_allType, at: 0)
        var firstIndex = 0
        
        for (index, aacCategory) in aacCategoryModels.enumerated() {
            let setWidth: CGFloat = aacCategory.category.width(withConstrainedHeight: 34, font: UIFont.systemFont(ofSize: 16)) + 32
            let btn = NaviUtility.CreateCustomBtn(aacCategory.category)
            btn.tag = aacCategory.aac_id
            btn.frame = CGRect(x: maxX, y: 8, width: setWidth, height: 34)
            btn.layer.cornerRadius = 17
            btn.layer.addShadow()
            btn.addTarget(self, action: #selector(pressCategoryBtn(_:)), for: .touchUpInside)
            self.aacCategoryBtns.append(btn)
            scrollView.addSubview(btn)
            maxX = btn.frame.maxX + 8
            if aacCategory.aac_id == self.current_aac_id {
                firstIndex = index
            }
        }
        
        maxX += 16
        scrollView.contentSize = CGSize(width: maxX, height: 50)
        self.pressAacCategoryBtn(at: firstIndex)
    }
    
    @objc private func pressCategoryBtn(_ btn: UIButton) {
        self.current_ac_id = nil
        let pressed_aac_id = btn.tag
        guard let btnIndex = self.aacCategoryBtns.firstIndex(of: btn) else {
            return
        }
        if pressed_aac_id == 0 {
            self.current_aac_id_array = [0]
            self.pressAacCategoryBtn(at: btnIndex)
        }else {
            if self.current_aac_id_array == [0] {
                self.current_aac_id_array = []
                self.navPresenter.unSelectAll(self.aacCategoryBtns)
            }
            if self.current_aac_id_array.contains(pressed_aac_id), let arrayIndex = current_aac_id_array.firstIndex(of: pressed_aac_id) {
                self.current_aac_id_array.remove(at: arrayIndex)
                self.navPresenter.unSelect(at: btnIndex, self.aacCategoryBtns)
            }else {
                self.current_aac_id_array.append(pressed_aac_id)
                self.navPresenter.select(at: btnIndex, self.aacCategoryBtns)
            }
        }
        self.showMarkers(by: self.pickedPlanId, ac_id: self.current_ac_id, aac_id: self.current_aac_id, aac_ids: self.current_aac_id_array)
    }

    private func pressAacCategoryBtn(at index: Int) {
        self.navPresenter.unSelectAll(self.aacCategoryBtns)
        self.navPresenter.select(at: index, self.aacCategoryBtns)
    }
}

extension MapVC: floorMenuDelegate {
    func didPickFloor(number: Int, dispatchGroup: DispatchGroup?) {
        //顯示朋友
        self.pickedFloorNumber = String(number)
        self.showUserAndArrowMarker(by: String(number))
        self.showFloorContainer(show: false)
        self.showTile(planId: NaviUtility.GetPlanId(by: number))

        let floorName = NaviUtility.GetFloorName(by: number)
        self.floorBtn.setTitle(floorName, for: .normal)

        // 呈現路線(若有)
        self.showPolyLine(floorNumber: self.pickedFloorNumber, completion: {focusedPath in
                                        
            if let dispatchGroup = dispatchGroup, NaviUtility.DispatchGroupCount(group: dispatchGroup) != nil {
                dispatchGroup.leave()
            }
                       
            guard (focusedPath != nil) else {
                return
            }
            
            self.focusedPath = focusedPath
            NaviUtility.fitPath(path: self.focusedPath, mapView: self.mapView)
            NaviUtility.RotateDirectionMarkers(mapBearing: self.currentMapBearing,
                                                 markers: self.showedDirectionMarkers)
            self.determineRefreshArrow()
        })
    }
    
    func showFloorContainer(show: Bool) {
        self.floorContainer.alpha = (show) ? 1:0
        self.floorBtn.alpha = (show) ? 0:1
    }
}

extension MapVC {
    func showGatherView() {
        let margin = self.view.safeAreaLayoutGuide
        let gatherView = UIView()
        gatherView.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        gatherView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(gatherView)

        let gatherPointBtn = UIButton()
        gatherPointBtn.translatesAutoresizingMaskIntoConstraints = false
        gatherPointBtn.addTarget(self, action: #selector(self.gatherAlert), for: .touchUpInside)
        gatherPointBtn.setTitle("建立集合點", for: .normal)
        gatherPointBtn.titleLabel?.textColor = UIColor.white
        gatherPointBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        gatherPointBtn.backgroundColor = #colorLiteral(red: 0, green: 0.4431372549, blue: 0.7137254902, alpha: 1)
        gatherPointBtn.layer.borderWidth = 2
        gatherPointBtn.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        gatherPointBtn.layer.cornerRadius = gatherPointBtn.frame.height/2
        
        gatherView.addSubview(gatherPointBtn)
        
        self.gatherTitle.translatesAutoresizingMaskIntoConstraints = false
        self.gatherTitle.minimumScaleFactor = 0.5
        gatherView.addSubview(self.gatherTitle)

        NSLayoutConstraint.activate([
            gatherView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            gatherView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            gatherView.bottomAnchor.constraint(equalTo: margin.bottomAnchor),
            gatherView.heightAnchor.constraint(equalToConstant: 50),
            gatherPointBtn.trailingAnchor.constraint(equalTo: gatherView.trailingAnchor, constant: -20),
            gatherPointBtn.centerYAnchor.constraint(equalTo: gatherView.centerYAnchor),
            gatherPointBtn.widthAnchor.constraint(equalToConstant: 90),
            gatherPointBtn.heightAnchor.constraint(equalToConstant: 34),
            self.gatherTitle.leadingAnchor.constraint(equalTo: gatherView.leadingAnchor, constant: 20),
            self.gatherTitle.trailingAnchor.constraint(equalTo: gatherView.trailingAnchor, constant: 20),
            self.gatherTitle.centerYAnchor.constraint(equalTo: gatherView.centerYAnchor)
        ])
    }
    
    func changGather(marker: GMSMarker) {
        self.gatherTitle.text = marker.title
        
        guard let poiModel = NaviUtility.GetPoiModel(by: marker) else {
            return
        }

        self.gatherPoi = poiModel
    }
    
    @objc func gatherAlert() {
        guard let gatherPoi = self.gatherPoi else {
            return
        }
        
        let poiName = self.gatherPoi.name
        let alert = UIAlertController(title: "確定在此集合？", message: poiName, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "確定", style: .destructive, handler: {[weak self]_ in
            self!.didChooseGatherPoi(gatherPoi)
            self?.navigationController?.popViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.showByTopVC()
    }
}

//MARK: - NavigationBottomGuideVC Delegate
extension MapVC: NavigationBottomGuideVCDelegate {
    func navBottomGuideVCDidPressSimulateBtn() {
        setNavBottomGuideHidden(true)
        startSimulateGuide()
    }
    
    func navBottomGuideVCDidPressNavBtn() {
        setNavBottomGuideHidden(true)
        startGuide()
    }
    
    private func setNavBottomGuideHidden(_ isHidden: Bool) {
        navBottomGuideView.isHidden = isHidden
        viewBottomView.isHidden = isHidden
    }
}

extension MapVC {
    func search(_ point: OGPointModel) {
        //1.切換圖層至「全部」類別
        self.pressCategoryBtn(self.aacCategoryBtns[0])

        //2.先zoom到最大，為了過濾showedMarkers
        self.zoomToMax(completion: {
                        
            //4-1圖層類別設為「全部」
            self.current_aac_id = 0
            self.current_aac_id_array = [0]
            
            //4-2切換樓層
            self.changeFloor(point.number, completion: {
                
                //5.找出poi對應marker
                guard let searchedMarker = self.showedMarkers.filter({($0.userData as? Int) == point.id}).first else {
                    return
                }
                                    
                //6.移動到poi位置
                let position = CLLocation(latitude: searchedMarker.position.latitude, longitude: searchedMarker.position.longitude)
                self.moveTo(location: position, zoom: self.locateZoom)

                //7.顯示資訊版
                self.mapDelegate?.map(didSelect: searchedMarker)
                                    
                //8.標示marker
                self.tapMarkerRefresh(marker: searchedMarker)
            })
        })
    }
}
