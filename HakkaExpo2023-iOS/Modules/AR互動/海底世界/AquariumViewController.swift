//
//  AquariumViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/23.
//

import UIKit
import ARKit

class AquariumViewController: UIViewController {
    
    @IBOutlet weak var arView: ARSCNView!
    
    private var modelsPlacedCount = 0
    private var maxBubbleCount = 100
    private var model1: SCNNode!
    private var model2: SCNNode!
    private var clockwise: Bool = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "海底世界"
        self.setupARKit()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        loadAndPlace3dModel()
    }
    
    
    private func setupARKit() {
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        arView.delegate = self
       
    }
    
    private func loadAndPlace3dModel() {
        HudManager.shared.showProgressWithMessage("海洋生物抵達中", seconds: 3.0)
//        startRandomlyPlacingModels()
        placeWhales()
    }
    
    
    private func startRandomlyPlacingModels() {
           for _ in 0..<maxBubbleCount {
               placeBubbleModel()
           }
       }
       
       private func placeBubbleModel() {
           let distance = Float.random(in: 0...10)
           let angle = Float.random(in: 0...(2 * Float.pi))
           let x = distance * cos(angle)
           let z = distance * sin(angle)
           let y = Float.random(in: 0...0.5)
           
           guard let modelNode = MarineLife3DModel(modelName: Configs.ModelNames.bubble).getNode() else {
               return
           }
           
           // 設定模型節點的位置
           let position = SCNVector3(x, y, z)
           modelNode.position = position
           
           // 將模型節點添加到場景中
           arView.scene.rootNode.addChildNode(modelNode)
           
           // 更新已放置模型計數
//           modelsPlacedCount += 1
//           if modelsPlacedCount >= maxBubbleCount {
//               // 已放置足夠數量的模型，停止放置
//               arView.delegate = nil
//           }
       }
    
    private func placeWhales() {
        let blueWhale = MarineLife3DModel(modelName: Configs.ModelNames.whaleSwinNew).getNode()
        let distance = Float.random(in: 5...10)
        let angle = Float.random(in: 0...(2 * Float.pi))
        let x = distance * cos(angle)
        let z = distance * sin(angle)
        let y = Float.random(in: 0.5...3)
        let positionBW = SCNVector3(0, 0, 1)
        blueWhale?.position = positionBW
        let scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
//        blueWhale?.scale = scale
        arView.scene.rootNode.addChildNode(blueWhale!)

//        let swimWhale = MarineLife3DModel(modelName: Configs.ModelNames.whaleSwim).getNode()
//        let positionSW = SCNVector3(0, 0, 3)
//        swimWhale?.position = positionSW
//        swimWhale?.scale = scale
//        model2 = swimWhale
//        arView.scene.rootNode.addChildNode(model2!)
    }

}


extension AquariumViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("DidAdd: \(node)")
    }
}
