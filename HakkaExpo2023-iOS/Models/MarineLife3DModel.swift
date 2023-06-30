//
//  MarineLife3DModel.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/23.
//

import SceneKit
import GLTFSceneKit


class MarineLife3DModel {
    
    private let scene: SCNScene
    
    init(modelName: String) {
        
        
        guard let bundle = Bundle(identifier: "omniguider.HakkaExpo2023-iOS.com") else {
            fatalError("無法找到指定的bundle")
        }
        
        guard let url = bundle.url(forResource: modelName, withExtension: "glb", subdirectory: "art.scnassets/under_the_sea") else {
            fatalError("讀取GLB檔案時出錯: \(modelName)")
        }
        
        do {
            let sceneSource = GLTFSceneSource(url: url)
            scene = try sceneSource.scene()
            
        } catch {
            fatalError("解析GLB檔案失敗: \(error.localizedDescription)")
        }
    }
    
    func getNode() -> SCNNode? {
        
        let node = scene.rootNode.clone()
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.4950331126)
        lightNode.position = SCNVector3(0, 10, 0)
        node.addChildNode(lightNode)
        
//        let material = SCNMaterial()
//        material.lightingModel = .physicallyBased
//        material.metalness.contents = 0.8
//        material.roughness.contents = 0.2
//        node.geometry?.materials = [material]
        
        return node
    }
}
