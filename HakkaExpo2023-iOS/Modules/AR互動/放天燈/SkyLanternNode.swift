//
//  SkyLanternNode.swift
//  OmniArTaipei
//
//  Created by Dong on 2022/11/24.
//

import Foundation
import GLTFSceneKit
import ARKit

class SkyLanternNode: SCNNode {
    
    static let maxTime: TimeInterval = 80
    static let maxHeight: Double = 20
    
    private let currentBundle = Bundle(for: SkyLanternNode.self)
    
    private let maxTime = SkyLanternNode.maxTime
    private let maxHeight = SkyLanternNode.maxHeight
    
    init(timestamp: Double, isTest: Bool) {
        super.init()
        setDefaultNode() {
            self.setDefaultMaterial()
            if !isTest {
                self.setPositionAndRunAction(timestamp)
            }
        }
    }
    
    init(userImage: UIImage) {
        super.init()
        setDefaultNode() {
            self.updateMaterial(with: userImage)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setPositionAndRunAction(_ timeInterval: Double) {
        //備註：80秒飛20公尺
        let time = Date().timeIntervalSince1970 - timeInterval
        guard time < maxTime else {return}
        let setHeight = Float(maxHeight * time / maxTime)
        position = SCNVector3(0, setHeight, 0)
        let lastPosition = SCNVector3(0, maxHeight, 0)
        let duration = maxTime - time
        let flyAction = SCNAction.move(by: lastPosition, duration: duration)
        runAction(flyAction, completionHandler: {
            if self.parent != nil {
                self.removeFromParentNode()
            }
        })
    }
    
    func runActionByUser() {
        let lastPosition = SCNVector3(0, maxHeight, 0)
        let duration = maxTime
        let flyAction = SCNAction.move(by: lastPosition, duration: duration)
        runAction(flyAction, completionHandler: {
            if self.parent != nil {
                self.removeFromParentNode()
            }
        })
    }
    
    func updateMaterial(with image: UIImage) {
        guard
            let path = SkyLanternResources.materialPath,
            let skyLampImage = UIImage(contentsOfFile: path),
            let lastGeometry = getLastGeometry(self)
        else {return}
        
        let size = skyLampImage.size
        UIGraphicsBeginImageContext(size)
        skyLampImage.draw(in: CGRect(x: 0,
                                     y: 0,
                                     width: size.width,
                                     height: size.height))
        image.draw(in: CGRect(x: size.width * 0.25,
                              y: size.height * 0.2,
                              width: size.width / 3,
                              height: size.height / 4.8))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let newImage {
            lastGeometry.firstMaterial?.diffuse.contents = newImage
        }else {
            lastGeometry.firstMaterial?.diffuse.contents = skyLampImage
        }
    }
    
    private func setDefaultNode(_ completion: @escaping (()->())) {
        DispatchQueue.global().async {
            guard let node = self.getGLBNode() else {return}
            DispatchQueue.main.async {
                self.addChildNode(node)
                if let fireNode = self.getFireNode() {
                    let scale = 0.005
                    fireNode.scale = SCNVector3(scale, scale, scale)
                    fireNode.position = SCNVector3(0, 1, 0)
                    fireNode.eulerAngles.z = .pi
                    self.addChildNode(fireNode)
                }
                
                let scaleValue = 0.4
                self.scale = SCNVector3(scaleValue, scaleValue, scaleValue)
                completion()
            }
        }
    }
    
    private func setDefaultMaterial() {
        guard
            let path = SkyLanternResources.materialPath,
            let image = UIImage(contentsOfFile: path),
            let lastGeometry = getLastGeometry(self)
        else {return}
        lastGeometry.firstMaterial?.diffuse.contents = image
    }
    
    /**取得天燈模型*/
    private func getGLBNode() -> SCNNode? {
        guard let sceneSource = SkyLanternResources.shared.getSceneSource() else {return nil}
        do {
            let scene = try sceneSource.scene()
            return scene.rootNode
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /**取得SCNNode最底層的SCNGeometry*/
    private func getLastGeometry(_ node: SCNNode) -> SCNGeometry? {
        if node.geometry != nil {
            return node.geometry
        }else if let child = node.childNodes.first {
            return getLastGeometry(child)
        }else {
            return nil
        }
    }
}
