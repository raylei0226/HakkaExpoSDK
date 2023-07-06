//
//  PoiDetailInfoView.swift
//  NAVISDK
//
//  Created by Jimmy Zhong on 2019/11/13.
//  Copyright © 2019 omniguider. All rights reserved.
//

import UIKit

protocol PoiDetailInfoDelegate: AnyObject {
    func poiDetailInfo(didTapped type:PoiDetailInfoView.ViewType)
}

class PoiDetailInfoView: UIView {
    enum ViewType: Int {case position = 0, phone, web, time}
    
    private let rowHeight: CGFloat = 51
    
    weak var delegate: PoiDetailInfoDelegate?

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var webLabel: UILabel!
    @IBOutlet weak var webView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else {
            return
        }
        var index = 0
        
        for subView in stackView.arrangedSubviews {
            if subView == view {
                break
            }
            index += 1
        }
        delegate?.poiDetailInfo(didTapped: ViewType(rawValue: index)!)
    }
    
    func setup(_ poiModel: OGPointModel) {
        textView.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Bundle(for: PoiDetailInfoView.self).loadNibNamed(String(describing: PoiDetailInfoView.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
    }
}
