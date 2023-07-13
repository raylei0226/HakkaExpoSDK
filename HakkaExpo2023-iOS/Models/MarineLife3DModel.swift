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
    
    init(scene: SCNScene) {
        self.scene = scene
    }
    
    class func fromGLB(modelName: String) -> MarineLife3DModel? {
        guard let bundle = Bundle(identifier: "omniguider.HakkaExpo2023-iOS.com") else {
            fatalError("無法找到指定的 bundle")
        }
        
        guard let url = bundle.url(forResource: modelName, withExtension: "glb", subdirectory: "art.scnassets/under_the_sea") else {
            fatalError("讀取 GLB 檔案時出錯: \(modelName)")
        }
        
        do {
            let sceneSource = GLTFSceneSource(url: url)
            let scene = try sceneSource.scene()
            return MarineLife3DModel(scene: scene)
        } catch {
            fatalError("解析 GLB 檔案失敗: \(error.localizedDescription)")
        }
    }
    
    class func fromSCN(modelName: String) -> MarineLife3DModel? {
        guard let bundle = Bundle(identifier: "omniguider.HakkaExpo2023-iOS.com") else {
            fatalError("無法找到指定的 bundle")
        }
        
        guard let url = bundle.url(forResource: modelName, withExtension: "scn", subdirectory: "art.scnassets/fishDaeFiles") else {
            fatalError("讀取 SCN 檔案時出錯: \(modelName)")
        }
        
        do {
            if let sceneSource = SCNSceneSource(url: url, options: nil) {
                let scene = try sceneSource.scene(options: nil)
                return MarineLife3DModel(scene: scene)
            } else {
                return nil
            }
        } catch {
            fatalError("解析檔案失敗: \(modelName), \(error.localizedDescription)")
        }
    }
    
    func getNode() -> SCNNode? {
        return scene.rootNode
    }
}
