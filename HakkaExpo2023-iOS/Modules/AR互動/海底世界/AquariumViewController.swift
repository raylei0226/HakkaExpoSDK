//
//  AquariumViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/23.
//

import UIKit
import ARKit
import SceneKit


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
        arView.automaticallyUpdatesLighting = true
        arView.antialiasingMode = .multisampling4X
    }
    
    private func loadAndPlace3dModel() {
        HudManager.shared.showProgressWithMessage("海洋生物抵達中", seconds: 3.0)
        startRandomlyPlacingModels()
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
        
        let position = SCNVector3(x, y, z)
        modelNode.position = position
        
        arView.scene.rootNode.addChildNode(modelNode)
        
        // 更新已放置模型計數
        //           modelsPlacedCount += 1
        //           if modelsPlacedCount >= maxBubbleCount {
        //               // 已放置足夠數量的模型，停止放置
        //               arView.delegate = nil
        //           }
    }
    
    
    private func placeWhales() {
        
        let blueWhale = MarineLife3DModel(modelName: Configs.ModelNames.whaleSwim).getNode()
        let distance = Float.random(in: 6...12)
        let angle = Float.random(in: 0...(2 * Float.pi))
        let x = distance * cos(angle)
        let z = distance * sin(angle)
        let y = Float.random(in: 1...3)
        let positionBW = SCNVector3(x, y, z)
        blueWhale?.position = positionBW
        let scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
        blueWhale?.scale = scale
        arView.scene.rootNode.addChildNode(blueWhale!)
        
        let swimWhale = MarineLife3DModel(modelName: Configs.ModelNames.whaleSwim).getNode()
        let positionSW = SCNVector3(0, 0, 20)
        swimWhale?.position = positionSW
        model2 = swimWhale
        
        arView.scene.rootNode.addChildNode(model2!)
    }
    
    func createTaiangleNode() -> SCNNode {
        let triangleNode = SCNNode()
        
        guard let model1 = MarineLife3DModel(modelName: Configs.ModelNames.bubble).getNode(),
              let model2 = MarineLife3DModel(modelName: Configs.ModelNames.bubble).getNode(),
              let model3 = MarineLife3DModel(modelName: Configs.ModelNames.bubble).getNode() else {
            return triangleNode
        }
        
        let scale = SCNVector3(0.1, 0.1, 0.1)
        
        model1.position = SCNVector3(x: 0, y: 0, z: 0)
        model1.scale = scale
        model2.position = SCNVector3(x: 1, y: 0, z: 0)
        model2.scale = scale
        model3.position = SCNVector3(x: 0.5, y: 1, z: 0)
        model3.scale = scale
        
        triangleNode.addChildNode(model1)
        triangleNode.addChildNode(model2)
        triangleNode.addChildNode(model3)
        
        return triangleNode
    }
    
    func moveNodeRandomly(node: SCNNode, distancePerSecond: Float) {
        let randomX = Float.random(in: -1.0...1.0)
        let randomZ = Float.random(in: -1.0...1.0)
        let direction = SCNVector3(randomX, 0, randomZ).normalized()
        let velocity = SCNVector3(direction.x * distancePerSecond, direction.y * distancePerSecond, direction.z * distancePerSecond)
        
        let moveAction = SCNAction.move(by: velocity, duration: 1.0)
        let repeatAction = SCNAction.repeatForever(moveAction)
        node.runAction(repeatAction)
    }

   
    
    func createRandomNodes(count: Int, originalNode: SCNNode) -> [SCNNode] {
        var nodes: [SCNNode] = []
        
        for _ in 1...count {
            // Create a random position within a radius of 20 meters
            let randomDistance = Float.random(in: 3...20)
            let randomAngle = Float.random(in: 0...(2 * .pi))
            let x = randomDistance * cos(randomAngle)
            let z = randomDistance * sin(randomAngle)
            let position = SCNVector3(x, 0, z)
            
            // Create a copy of the original node
            let copyNode = originalNode.clone()
            copyNode.position = position
            
            // Randomly move the copied node
            let randomMoveX = Float.random(in: -5...5)
            let randomMoveY = Float.random(in: -5...5)
            let randomMoveZ = Float.random(in: -5...5)
            let moveAction = SCNAction.moveBy(x: CGFloat(randomMoveX), y: CGFloat(randomMoveY), z: CGFloat(randomMoveZ), duration: 1.0)
            let repeatAction = SCNAction.repeatForever(moveAction)
            copyNode.runAction(repeatAction)
            
            // Add the copied node to the array
            nodes.append(copyNode)
        }
        
        return nodes
    }
}



extension AquariumViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("DidAdd: \(node)")
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    }
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180}
}

extension SCNVector3 {
    func normalized() -> SCNVector3 {
        let length = sqrt(x * x + y * y + z * z)
        return SCNVector3(x / length, y / length, z / length)
    }
}




