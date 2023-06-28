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
        
        guard let url = bundle.url(forResource: modelName, withExtension: "glb", subdirectory: "art.scnassets") else {
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
        
        return scene.rootNode.clone()
    }
}
