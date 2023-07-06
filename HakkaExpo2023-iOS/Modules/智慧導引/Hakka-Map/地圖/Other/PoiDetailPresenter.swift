//
//  PoiDetailPresenter.swift
//  NAVISDK
//
//  Created by Jimmy Zhong on 2019/11/11.
//  Copyright © 2019 omniguider. All rights reserved.
//

import Foundation
import CoreLocation

protocol PoiDetailPresenterDelegate: AnyObject {
    func poiDetail(didUpdate point: OGPointModel)
    func poiDetailDidEndCollect(_ pointName: String, result: PoiDetailPresenter.FavoriteResult)
}

class PoiDetailPresenter {
    
    enum FavoriteResult {case addSuccess, deleteSuccess, failed}
    
    weak var delegate: PoiDetailPresenterDelegate?
    
    private var point: InfoPoint?
    private(set) var titleViewType: PoiDetailTitleView.ViewType!
    var pointNoContent: Bool {
        return point?.noContent ?? true
    }
    
    func saveTitleViewType(_ type: PoiDetailTitleView.ViewType) {
        titleViewType = type
    }
    
    func update(_ poiModel: OGPointModel) {
        delegate?.poiDetail(didUpdate: poiModel)
    }
    
    //MARK: - Record
    func setFavorite(_ p_id: Int, with token: String) {
    }
    
    //MARK: - Coordinate
    func pointToNavigate() -> InfoPoint? {
        return point
    }
    
    //MARK: - Position
    func validatedGoogleMapUrl() -> URL? {
        guard
            let urlString = "https://www.google.com/maps/?saddr=&daddr=\(point?.address ?? "")&views=traffic".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlString), UIApplication.shared.canOpenURL(url)
        else {
            return nil
        }
        return url
    }
    
    //MARK: - Phone
    func validatedPhoneUrl() -> URL? {
        guard
            let url = URL(string: "tel://\(point?.tel ?? "")"),
            UIApplication.shared.canOpenURL(url)
        else {
            return nil
        }
        return url
    }
    
    //MARK: - Web
    func validatedWebUrl() -> URL? {
        guard
            let url = URL(string: point?.web ?? ""),
            UIApplication.shared.canOpenURL(url)
        else {
            return nil
        }
        return url
    }
}
