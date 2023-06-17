//
//  CustomMaskView.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/17.
//

import UIKit

class CustomMaskView: UIView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // 設置填充顏色
        let fillColor = UIColor.black.withAlphaComponent(0.6)
        
        // 計算四邊形的位置和大小
        let squareSize: CGFloat = rect.width * 0.7
        let squareRect = CGRect(x: (rect.width - squareSize) / 2.0,
                                y: (rect.height - squareSize) / 2.0,
                                width: squareSize,
                                height: squareSize)
        
        // 填充整個視圖的背景顏色
        fillColor.setFill()
        UIRectFill(rect)
        
        // 創建帶有圓角的路徑
        let roundedPath = UIBezierPath(roundedRect: squareRect, cornerRadius: squareSize * 0.12)
        roundedPath.addClip()
        
        // 設置四邊形的填充顏色
        UIColor.clear.setFill()
        UIRectFill(squareRect)
        
        
        // 用填充顏色繪製四邊形邊框
        context.setStrokeColor(fillColor.cgColor)
        context.setLineWidth(2.0)
//        context.addRect(squareRect)
//        context.strokePath()
        roundedPath.stroke()
    }
}
