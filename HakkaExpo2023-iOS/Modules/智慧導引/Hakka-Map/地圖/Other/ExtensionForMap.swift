//
//  ExtensionForMap.swift
//  HakkaExpo2023-iOS
//
//  Created by Dong on 2023/7/4.
//

import Foundation
import CoreLocation
import UIKit
import GoogleMaps

//MARK: - Variables
var phoneBottomInset: CGFloat {
    return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? .zero
}

//MARK: - Notification Name
extension Notification.Name {
    static let readyRouteData = Notification.Name(rawValue: "readyRouteData")
    static let reloadHistoricalKeyword = Notification.Name(rawValue: "reloadHistoricalKeyword")
}

//MARK: - CLLocationCoordinate2D
extension CLLocationCoordinate2D {
    func distance(to otherPoint: CLLocationCoordinate2D) -> Double {
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let otherLocation = CLLocation(latitude: otherPoint.latitude, longitude: otherPoint.longitude)
        return location.distance(from: otherLocation)
    }
    
    var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
}

//MARK: - String
extension String {
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    var languageCodeWithoutRegion: String {
        var components = self.components(separatedBy: "-")
        components.remove(at: components.count - 1)
        var languageCode = ""
        for component in components{
            if languageCode != "" {
                languageCode += "-"
            }
            languageCode += component
        }
        return languageCode
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}

//MARK: - UIView
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
}

//MARK: - UIViewController
extension UIViewController {
    func showByTopVC() {
        if var topVC = UIApplication.shared.keyWindow?.rootViewController {
            while let nextVC = topVC.presentedViewController {
                topVC = nextVC
            }
            DispatchQueue.main.async {
                topVC.present(self, animated: true, completion: nil)
            }
        }
    }
}

//MARK: - UIImage
extension UIImage {
    func poiDirectionImage(id: Int, bundle: Bundle) -> UIImage? {
        switch id {
        case 20000: // 方向marker
            return UIImage(named: "direction", in: bundle, compatibleWith: nil)
        case 10000: // 起點
            return UIImage(named: "beginPoint", in: bundle, compatibleWith: nil)
        case 10001: // 終點
            return UIImage(named: "icon_select", in: bundle, compatibleWith: nil)
        default:
            return nil
        }
    }
    
    class func textWithImage(drawText: String, inImage: UIImage) -> UIImage {
        let dynamicView = UIView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 40, height: 40)))
        dynamicView.backgroundColor = UIColor.clear
        var imageViewForPinMarker: UIImageView
        imageViewForPinMarker = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 40, height: 40)))
        imageViewForPinMarker.image = inImage
        
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        textLabel.textColor = .white
        textLabel.text = drawText
        textLabel.font = UIFont(name: textLabel.font.fontName, size: 14)
        textLabel.textAlignment = NSTextAlignment.center
        imageViewForPinMarker.addSubview(textLabel)
        dynamicView.addSubview(imageViewForPinMarker)
        UIGraphicsBeginImageContextWithOptions(dynamicView.frame.size, false, UIScreen.main.scale)
        dynamicView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageConverted: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return imageConverted
    }
    
    class func icon(name: String, bundle: Bundle) -> UIImage {
        return UIImage(named: name, in: bundle, compatibleWith: nil) ?? UIImage()
    }
    
    func poiTypeToImage(ac_id: Int?, isSelected: Bool = false, bundle: Bundle) -> UIImage? {
        if isSelected {
            return UIImage.icon(name: "poi_hakka_select", bundle: bundle)
        }else {
            return UIImage.icon(name: "poi_hakka", bundle: bundle)
        }
    }
}

//MARK: - UIImageView
extension UIImageView {
    func setSlideIcon(direction: SlideDirection, bundle: Bundle) {
        let iconString = (direction == .up) ? "pull_up" : "pull_down"
        
        let animate = UIViewPropertyAnimator(duration: 0.3, curve: .linear, animations: {
            self.alpha = 0
        })
        
        animate.addCompletion({_ in
            self.image = UIImage(named: iconString, in: bundle, compatibleWith: nil)
            let animate = UIViewPropertyAnimator(duration: 0.3, curve: .linear, animations: {
                self.alpha = 1
            })
            animate.startAnimation()
        })
        
        animate.startAnimation()
    }
}

//MARK: - UIStackView
extension UIStackView {
    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach {view in
            removeFully(view: view)
        }
    }
    
    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
}

//MARK: - CALayer
extension CALayer {
    func addShadow(_ offsetSize: CGSize = .zero, radius: CGFloat = 5) {
        self.shadowOffset = offsetSize
        self.shadowOpacity = 0.2
        self.shadowRadius = radius
        self.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.masksToBounds = false
        
        if cornerRadius != 0 {
            self.addShadowWithRoundedCorners()
        }
    }
    
    func roundCorners(radius: CGFloat) {
        self.cornerRadius = radius
        
        if shadowOpacity != 0 {
            self.addShadowWithRoundedCorners()
        }
    }
    
    private func addShadowWithRoundedCorners() {
        masksToBounds = false
        
        sublayers?.filter{ $0.frame.equalTo(self.bounds) }
            .forEach{ $0.roundCorners(radius: self.cornerRadius) }
        
        self.contents = nil
        
        if let sublayer = sublayers?.first, sublayer.name == "addShadowWithRoundedCorners" {
            sublayer.removeFromSuperlayer()
        }
        
        let contentLayer = CALayer()
        contentLayer.name = "addShadowWithRoundedCorners"
        contentLayer.contents = contents
        contentLayer.frame = bounds
        contentLayer.cornerRadius = cornerRadius
        contentLayer.masksToBounds = true
        insertSublayer(contentLayer, at: 0)
    }
}

//MARK: - GMSURLTileLayer
extension GMSURLTileLayer {
    func setOpacity(_ isNavigating: Bool) {
        self.opacity = (isNavigating == true) ? 0.7 : 1
    }
}
