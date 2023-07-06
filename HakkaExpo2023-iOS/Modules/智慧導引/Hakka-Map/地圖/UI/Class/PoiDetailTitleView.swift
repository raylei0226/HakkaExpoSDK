//
//  PoiDetailTitleView.swift
//  NAVISDK
//
//  Created by Jimmy Zhong on 2019/11/11.
//  Copyright © 2019 omniguider. All rights reserved.
//

import UIKit

protocol PoiDetailTitleDelegate: AnyObject {
    func poiDetailTitle(didPressed btnType: PoiDetailTitleView.BtnType)
    func poiDetailTitle(didAdd point: InfoPoint)
    func poiDetailTitleDidTapSwipeBar()
}

class PoiDetailTitleView: UIView {
    enum ViewType {case normal, choose, group}
    enum BtnType {case navigation, collect(Int)}
    
    weak var delegate: PoiDetailTitleDelegate?

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var swipeBar: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var navBtn: UIButton!
    
    var point: InfoPoint!
    
    func setupTitle(_ poiModel: OGPointModel) {
        self.swipeBar.setSlideIcon(direction: .up, bundle: Bundle(for: PoiDetailVC.self))
        let floorNumber = NaviUtility.GetFloorName(by: poiModel.number)
        titleLabel.text = "\(floorNumber)-\(poiModel.name) "
    }
    
    func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapSwipeBar))
        self.swipeBar.addGestureRecognizer(tap)
        self.swipeBar.isUserInteractionEnabled = true
    }
    
    @objc func tapSwipeBar() {
        self.delegate?.poiDetailTitleDidTapSwipeBar()
    }

    func setup(_ type: ViewType, delegate: PoiDetailTitleDelegate) {
        self.delegate = delegate
        self.addTap()
        navBtn.isHidden = type != .normal
        
        navBtn.layer.cornerRadius = 8
    }
    
    func clear() {
    }
    
    @IBAction func pressNaviBtn(_ sender: Any) {
        delegate?.poiDetailTitle(didPressed: .navigation)
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        let vc = UIActivityViewController(activityItems: [shareContent()], applicationActivities: nil)
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func phoneBtnPressed(_ sender: Any) {
        if point.tel == "" {return}
        if let url = URL(string: "tel://\(point.tel)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func timetableBtnPressed(_ sender: Any) {
    }
    
    @IBAction func collectionBtnPressed(_ sender: Any) {
        delegate?.poiDetailTitle(didAdd: point)
    }
    
    private func shareContent() -> String {
        var content = "\(point.localizedName)\n\n\(point.localizedInfo)\n\n"
        if point.address != "" {
            content += "\(point.address)\n"
        }
        if point.tel != "" {
            content += "\(point.tel)\n"
        }
        if URL(string: point.image) != nil {
            content += "\(point.image)\n"
        }
        content += "\n***更多服務請前往下載森遊阿里山Alipedia APP\n"
        content += "https://apps.apple.com/tw/app/id1491273055"
        return content
    }
    
    private func setBtns() {
        navBtn.setTitle(" 路徑規劃", for: .normal)
        navBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        navBtn.titleLabel?.minimumScaleFactor = 0.5
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        Bundle(for: PoiDetailTitleView.self).loadNibNamed(String(describing: PoiDetailTitleView.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        setBtns()
    }
}
