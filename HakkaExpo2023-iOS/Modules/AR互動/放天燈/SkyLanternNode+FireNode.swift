//
//  SkyLanternNode+FireNode.swift
//  OmniArTaipei
//
//  Created by Dong on 2022/11/30.
//

import Foundation
import SceneKit
import SpriteKit

extension SkyLanternNode {
    func getFireNode() -> SCNNode? {
        guard
            let url = SkyLanternResources.firePathUrl,
            let sprite = CustomSprite(with: url)
        else {return nil}
        sprite.beginAnimation()
        
        let size = sprite.contentSize
        
        let skScene = SKScene(size: size)
        skScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        skScene.backgroundColor = .clear
        skScene.addChild(sprite)
        
        let plane = SCNPlane(width: size.width, height: size.height)
        plane.firstMaterial?.diffuse.contents = skScene
        let rectNode = SCNNode(geometry: plane)
        
        return rectNode
    }
}

//MARK: - Other
class CustomSprite: SKSpriteNode {
    private var textureArr = [SKTexture]()
    private(set) var contentSize: CGSize = .zero
    
    init?(with url: URL) {
        guard
            let images = CustomSprite.load(with: url),
            let image = images.first
        else {return nil}
        let texture = SKTexture(image: image)
        super.init(texture: texture, color: .clear, size: texture.size())
        contentSize = texture.size()
        images.forEach({textureArr.append(SKTexture(image: $0))})
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func load(with url: URL) -> [UIImage]? {
        guard
            let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)
        else {return nil}
        
        let numberOfImages = CGImageSourceGetCount(imageSource)
        var images = [UIImage]()
        for i in 0...numberOfImages {
            if let cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil) {
                let frame = UIImage(cgImage: cgImage)
                images.append(frame)
            }
        }
        return images
    }

    func beginAnimation() {
        let animate = SKAction.animate(with: textureArr, timePerFrame: 0.1)
        let forever = SKAction.repeatForever(animate)
        run(forever)
    }
}
