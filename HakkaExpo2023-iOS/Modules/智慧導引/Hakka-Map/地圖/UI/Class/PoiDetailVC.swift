//
//  PoiDetailVC.swift
//  NAVISDK
//
//  Created by Jimmy Zhong on 2019/11/11.
//  Copyright © 2019 omniguider. All rights reserved.
//

import UIKit
import SafariServices
import CoreLocation

protocol PoiDetailDelegate: AnyObject {
    func poiDetail(didPressedNaviTo point: OGPointModel)
    func poiDetail(didPressedCollect p_id: Int)
    func poiDetail(didAdd point: InfoPoint)
    func poiDetailDidEndCollect()
}

extension PoiDetailDelegate {
    func poiDetail(didAdd point: InfoPoint){}
}

protocol PoiDetailPanDelegate: AnyObject {
    func poiDetailPan(didCollapse height: CGFloat)
    func poiDetailPan(didExpandFully height: CGFloat)
}

class PoiDetailVC: UIViewController, PoiDetailPresenterDelegate, UIScrollViewDelegate, PoiDetailInfoDelegate, PoiDetailTitleDelegate {
    
    weak var delegate: PoiDetailDelegate?
    weak var panDelegate: PoiDetailPanDelegate?
    
    private let presenter = PoiDetailPresenter()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleView: PoiDetailTitleView!
    @IBOutlet weak var infoView: PoiDetailInfoView!

    private var updateFromGuide: Bool = false
    private var updateFromGuidePoint: InfoPoint?
    private var canDismiss = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        self.titleView.setup(presenter.titleViewType, delegate: self)
        presenter.delegate = self
        infoView.delegate = self
    }
    
    //MARK: - Actions
    func initialize(_ titleType: PoiDetailTitleView.ViewType, delegate: PoiDetailDelegate, panDelegate: PoiDetailPanDelegate) {
        presenter.saveTitleViewType(titleType)
        self.delegate = delegate
        self.panDelegate = panDelegate
        presenter.delegate = self
    }
    
    func update(with poiModel: OGPointModel) {
        self.titleView.clear()
        presenter.saveTitleViewType(.normal)
        presenter.update(poiModel)
    }
    
    func updateFromGuide(with point: InfoPoint, delegate: PoiDetailDelegate) {
        updateFromGuidePoint = point
        updateFromGuide = true
        presenter.saveTitleViewType(.normal)
        self.delegate = delegate
        presenter.delegate = self
    }
    
    //MARK: - Poi Detail Presenter Delegate
    func poiDetail(didUpdate poiModel: OGPointModel) {
        self.titleView.setupTitle(poiModel)
        self.infoView.setup(poiModel)
        self.panDelegate?.poiDetailPan(didCollapse: titleView.viewHeight.constant)
    }
    
    func poiDetailDidEndCollect(_ pointName: String, result: PoiDetailPresenter.FavoriteResult) {
        switch result {
        case .addSuccess:
            NaviUtility.ShowAlert("已收藏「\(pointName)」")
        case .deleteSuccess:
            NaviUtility.ShowAlert("已移除收藏「\(pointName)」")
        case .failed:
            break
        }
        delegate?.poiDetailDidEndCollect()
    }
    
    //MARK: - Poi Detail Title Delegate
    func poiDetailTitle(didPressed btnType: PoiDetailTitleView.BtnType) {
        switch btnType {
        case .navigation:
            guard let point = GlobalState.endPoi else {
                return
            }
            delegate?.poiDetail(didPressedNaviTo: point)
        case .collect(let p_id):
            guard let token = UserDefaults.standard.string(forKey: "login_token") else {
                NaviUtility.ShowAlert("Please Login First.")
                return
            }
            delegate?.poiDetail(didPressedCollect: p_id)
            presenter.setFavorite(p_id, with: token)
        }
    }
    
    func poiDetailTitle(didAdd point: InfoPoint) {
        delegate?.poiDetail(didAdd: point)
    }
    
    func poiDetailTitleDidTapSwipeBar() {
        (self.titleViewPosition == .bottom) ? self.expand() : self.collapse()
    }

    //MARK: - Poi Detail Info Delegate
    func poiDetailInfo(didTapped type: PoiDetailInfoView.ViewType) {
        switch type {
        case .position:
            openGoogleMap()
        case .phone:
            callPhone()
        case .web:
            openWebUrl()
        case .time:
            break
        }
    }
    
    private func openGoogleMap() {
        if let url = presenter.validatedGoogleMapUrl() {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func callPhone() {
        if let url = presenter.validatedPhoneUrl() {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func openWebUrl() {
        if let url = presenter.validatedWebUrl() {
            let vc = SFSafariViewController(url: url)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: - Scroll View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -100 {
            collapse()
        }
    }
    
    //MARK: - Pan Actions
    @IBAction func viewPanned(_ sender: UIPanGestureRecognizer) {
        let y = sender.translation(in: view).y
        if sender.state == .ended {
            y < 0 ? expand() : collapse()
        }
    }
    
    enum TitleViewPosition {case top, bottom}
    var titleViewPosition: TitleViewPosition! = .bottom
    
    private func expand() {
        //若無說明文字，無法向上滑動
        if self.infoView.textView.text == "" {
            return
        }
        
        canDismiss = false
        panDelegate?.poiDetailPan(didExpandFully: UIScreen.main.bounds.height * 2/3)
        self.titleViewPosition = .top
    }
    
    func collapse() {
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        let newHeight = canDismiss ? 0 : self.titleView.viewHeight.constant
        (canDismiss == false) ? canDismiss = true : nil
        panDelegate?.poiDetailPan(didCollapse: newHeight)
        self.titleViewPosition = .bottom
    }
}
