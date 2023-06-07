//
//  SkyLanternCanvasView.swift
//  OmniArTaipei
//
//  Created by Dong on 2022/11/21.
//

import UIKit


class SkyLanternCanvasView: UIView {

    private(set) var lineColor = UIColor.black
    private(set) var lineWidth: CGFloat = 5
    
    private var path: UIBezierPath!
    private var touchPoint: CGPoint!
    private var startingPoint: CGPoint!
    private var pathArray = [UIBezierPath]()
    
    private var backgroundImageView: UIImageView!
    
    //MARK: - Action
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startingPoint = touches.first?.location(in: self)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPoint = touches.first?.location(in: self)
        if path == nil {path = UIBezierPath()}
        path.move(to: startingPoint)
        path.addLine(to: touchPoint)
        startingPoint = touchPoint
        draw()
    }
    
    private func draw() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(shapeLayer)
        setNeedsDisplay()
    }
    
    func setBackgroundImage(_ image: UIImage) {
        if backgroundImageView != nil {
            backgroundImageView.image = image
        }else {
            backgroundImageView = UIImageView(image: image)
            backgroundImageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            addSubview(backgroundImageView)
        }
    }
    
    func setLineType(withSize size: CGFloat, color: UIColor) {
        lineWidth = size
        lineColor = color
        pathArray.append(path)
        path = nil
    }
    
    func clearCanvas() {
        pathArray.forEach({$0.removeAllPoints()})
        path = nil
        layer.sublayers = nil
        setNeedsDisplay()
        if backgroundImageView != nil {
            backgroundImageView.removeFromSuperview()
            backgroundImageView = nil
        }
    }

    func convertImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image {rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        clipsToBounds = true
        isMultipleTouchEnabled = false
    }
}
