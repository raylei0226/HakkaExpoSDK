//
//  AquariumViewController.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/5/23.
//

import UIKit
import ARKit
import SceneKit
import GLTFSceneKit


class AquariumViewController: UIViewController {
    
    @IBOutlet weak var arView: ARSCNView!
    @IBOutlet weak var fishButton: UIButton!
    
    private var modelsPlacedCount = 0
    private var maxBubbleCount = 150
    private let modelHeightInterval: CGFloat = 2.0
    private var model1: SCNNode!
    private var model2: SCNNode!
    private var clockwise: Bool = true
    private var isPhotosBeingSaved: Bool = false
    private var takeingPhotoAvailable: Bool = false
    private lazy var modelScene = SCNScene()

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
        if takeingPhotoAvailable {
            guard !isPhotosBeingSaved else { return }
            isPhotosBeingSaved = true
            let image = arView.snapshot()
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
        } else {
            HudManager.shared.showProgressWithMessageAndDelay("載入中...", seconds: 5.0, completionHandler: loadAndPlace3dModel)
            setupCameraButton()
        }
    }
    
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error {
            AlertManager.showAlert(in: self, message: error.localizedDescription)
        }else {
            AlertManager.showAlert(in: self, title: "[相片已儲存]", actions: [UIAlertAction(title: "好", style: .cancel)])
        }
        isPhotosBeingSaved = false
    }
    
    
    //建立場景
    private func setupScene() {
        modelScene = SCNScene()
        let sphereGeometry = SCNSphere(radius: 30)
        let rangeNode = SCNNode(geometry: sphereGeometry)
        rangeNode.position = SCNVector3(x: 0, y: 0, z: 0)
        modelScene.rootNode.addChildNode(rangeNode)
        createRandomModelsWithinRange(rangeNode)
        arView.scene = modelScene
        cancelContentLight()
    }
    
    private func cancelContentLight() {
        // 遍歷所有物體的材質，並將其emission等屬性設置為不受燈光影響
        arView.scene.rootNode.enumerateHierarchy { (node, _) in
            if let geometry = node.geometry {
                for material in geometry.materials {
                    material.emission.contents = UIColor.clear // 或者其他你希望的顏色
                    material.lightingModel = .constant
                }
            }
        }
    }
    
    private func setupCameraButton() {
        takeingPhotoAvailable = true
        fishButton.setImage(UIImage(named: K.camera, in: Bundle(for: AquariumViewController.self), compatibleWith: nil), for: .normal)
    }
    
    private func setupARKit() {
        
        let configuration = ARWorldTrackingConfiguration()
        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true
        arView.session.run(configuration)
        arView.delegate = self
        arView.delegate = self
        
        
//        arView.antialiasingMode = .multisampling4X
    }
    
    
    private func createRandomModelsWithinRange(_ rangeNode: SCNNode) {
        
        let minHeight: Float = -1.0
        let maxHeight: Float = 5.0

        for _ in 0..<8 {
            let randomHeight = Float.random(in: minHeight...maxHeight)
            let randomPosition = generateRandomPositionWithinRange(rangeNode)
            let jellyNode = createTaiangleNode(with: Configs.ModelNames.moonJellyfish)
            jellyNode.scale = SCNVector3(0.2, 0.2, 0.2)
            jellyNode.position = SCNVector3(x: randomPosition.x, y: randomHeight, z: randomPosition.z)
            let light = SCNLight()
            light.type = .spot
            light.color = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
            jellyNode.light = light
            rangeNode.addChildNode(jellyNode)
            moveNodeBackAndForth(node: jellyNode, destinationPoint: SCNVector3(jellyNode.position.x, jellyNode.position.y - 1.5, jellyNode.position.z), duration: 15.0)
        }
        
        for _ in 0..<6 {
            let randomHeight = Float.random(in: -1.0...3.5)
            let randomPosition = generateRandomPositionWithinRange(rangeNode)
            if let turtleNode = MarineLife3DModel.fromGLB(modelName:  Configs.ModelNames.greenSeaTurtle)?.getNode() {
                turtleNode.scale = SCNVector3(0.3, 0.3, 0.3)
                turtleNode.position = SCNVector3(x: randomPosition.x, y: randomHeight, z: randomPosition.z)
                rangeNode.addChildNode(turtleNode)
                moveNodeToTargetAndBack(node: turtleNode, targetPosition: SCNVector3(x: generateRandomPositionWithinRange(rangeNode).x, y: generateRandomPositionWithinRange(rangeNode).y, z: 5.0), addAction: nil, duration: 30, rotateDuration: 5)
            }
        }
        
        for _ in 0..<1 {
            let randomHeight = Float.random(in: 5.5...7.0)
            if let whaleNode = MarineLife3DModel.fromGLB(modelName: Configs.ModelNames.whaleBlue)?.getNode() {
                whaleNode.scale = SCNVector3(1.5, 1.5, 1.5)
                whaleNode.position = SCNVector3(x: -20, y: randomHeight, z: -30)
                let rotateAction = SCNAction.rotateBy(x: 0, y: .pi / 2, z: 0, duration: 3.0)
                rangeNode.addChildNode(whaleNode)
                moveNodeToTargetAndBack(node: whaleNode, targetPosition: SCNVector3(x: 35, y: 0, z: 0), addAction: rotateAction, duration: 35, rotateDuration: 5)
            }
        }
        
        for _ in 0..<1 {
            if let whaleNode2 = MarineLife3DModel.fromGLB(modelName: Configs.ModelNames.whaleSwim)?.getNode() {
                whaleNode2.scale = SCNVector3(2.5, 2.5, 2.5)
                whaleNode2.position = SCNVector3(40, 40, 50)
                let rotateAction = SCNAction.rotateBy(x: 0, y: -90, z: 0, duration: 3.0)
                rangeNode.addChildNode(whaleNode2)
                moveNodeToTargetAndBack(node: whaleNode2, targetPosition: SCNVector3(x: -40, y: 40, z: 0), addAction: rotateAction, duration: 35, rotateDuration: 5)
            }
        }
        
        for _ in 0..<25 {
//            for _ in 0..<15 {
            let randomHeight = Float.random(in: 0.0...3.0)
            let randomPosition = generateRandomPositionWithinRange(rangeNode)
            if let stingrayNode = MarineLife3DModel.fromGLB(modelName: Configs.ModelNames.stingray)?.getNode() {
                stingrayNode.scale = SCNVector3(x: 2.5, y: 2.5, z: 2.5)
                stingrayNode.position = SCNVector3(randomPosition.x, randomHeight, randomPosition.z)
                rangeNode.addChildNode(stingrayNode)
                moveNodeToTargetAndBack(node: stingrayNode, targetPosition: SCNVector3(x: generateRandomPositionWithinRange(rangeNode).x,
                                                                                        y: generateRandomPositionWithinRange(rangeNode).y,
                                                                                       z: 25), addAction: nil, duration: 25, rotateDuration: 3)
            }
        }
        
        for _ in 0..<80 {
//            for _ in 0..<40 {
            let randimHeight = Float.random(in: 0.0...5.0)
            let randomPosition = generateRandomPositionWithinRange(rangeNode)
            if let clownfishNode = MarineLife3DModel.fromSCN(modelName: Configs.ModelNames.clownfish)?.getNode() {
                clownfishNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
                clownfishNode.position = SCNVector3(x: randomPosition.x, y: randimHeight, z: randomPosition.z)
                rangeNode.addChildNode(clownfishNode)
                let rotateAction = SCNAction.rotateBy(x: 0, y: (.pi / 2), z: 0, duration: 1.0)
                moveNodeToTargetAndBack(node: clownfishNode, targetPosition: SCNVector3(x: (clownfishNode.position.x), y: (clownfishNode.position.y), z: -15), addAction: rotateAction, duration:10, rotateDuration: 1.0)
            }
        }
        
        for _ in 0..<35 {
//            for _ in 0..<20 {
            let randimHeight = Float.random(in: -1.0...6.0)
            let randomPosition = Float.random(in: 10.0...20.0)
            if let angelfishNode = MarineLife3DModel.fromSCN(modelName: Configs.ModelNames.angelfish)?.getNode() {
                angelfishNode.scale = SCNVector3(x: 0.8, y: 0.8, z: 0.8)
                angelfishNode.position = SCNVector3(x: randomPosition, y: randimHeight, z: randomPosition)
                rangeNode.addChildNode(angelfishNode)
                let rotateAction = SCNAction.rotateBy(x: 0, y: (.pi / 2), z: 0, duration: 1.0)
                moveNodeToTargetAndBack(node: angelfishNode, targetPosition: SCNVector3(x: (angelfishNode.position.x), y: (angelfishNode.position.y), z: -10), addAction: rotateAction, duration:20, rotateDuration: 1.0)
            }
        }
        
        for _ in 0..<10 {
            let randimHeight = Float.random(in: -1.0...6.0)
            let randomPosition = Float.random(in: 1.0...3.0)
            if let doubleSaddleNode = MarineLife3DModel.fromSCN(modelName: Configs.ModelNames.doubleSaddle)?.getNode() {
                doubleSaddleNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
                doubleSaddleNode.position = SCNVector3(x: randomPosition, y: randimHeight, z: randomPosition)
                rangeNode.addChildNode(doubleSaddleNode)
                let rotateAction = SCNAction.rotateBy(x: 0, y: (.pi / 2 ), z: 0, duration: 1.0)
                moveNodeToTargetAndBack(node: doubleSaddleNode, targetPosition: SCNVector3(x: (doubleSaddleNode.position.x), y: (doubleSaddleNode.position.y), z: -5), addAction: rotateAction, duration:15, rotateDuration: 1.5)
            }
        }
        
        for _ in 0..<30 {
            let randimHeight = Float.random(in: -1.0...5.0)
            let randomPosition = Float.random(in: 1.0...3.0)
            if let clownfishNode = MarineLife3DModel.fromSCN(modelName: Configs.ModelNames.clownfish)?.getNode() {
                clownfishNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
                clownfishNode.position = SCNVector3(x: -10, y: randimHeight, z: randomPosition)
                rangeNode.addChildNode(clownfishNode)
                let rotateAction = SCNAction.rotateBy(x: 0, y: (.pi ), z: 0, duration: 1.0)
                moveNodeToTargetAndBack(node: clownfishNode, targetPosition: SCNVector3(x: 10, y: (clownfishNode.position.y), z: Float.random(in: 3.0...5.0)), addAction: rotateAction, duration:30, rotateDuration: 1.5)
            }
        }
        
//        for _ in 0..<50 {
            for _ in 0..<80 {
            let randimHeight = Float.random(in: -1.0...3.0)
//            let randomPosition = Float.random(in: 0.0...3.5)
            if let groupfishNode = MarineLife3DModel.fromSCN(modelName: Configs.ModelNames.yellowTang)?.getNode() {
                groupfishNode.scale = SCNVector3(x: 0.03, y: 0.03, z: 0.03)
                groupfishNode.position = SCNVector3(x: -10, y: randimHeight, z: 0)
                rangeNode.addChildNode(groupfishNode)
                let rotateAction = SCNAction.rotateBy(x: 0, y: (.pi / 2 ), z: 0, duration: 1.0)
                moveNodeToTargetAndBack(node: groupfishNode, targetPosition: SCNVector3(x: 10, y: (groupfishNode.position.y), z: Float.random(in: 3.0...5.0)), addAction: rotateAction, duration: 25, rotateDuration: 1.5)
            }
        }
    }


    private func generateRandomPositionWithinRange(_ rangeNode: SCNNode) -> SCNVector3 {
        
        let randomAngle = Float.random(in: 0...(2 * Float.pi))
        let randomRadius = Float.random(in: 1...10)
        let randomY = Float.random(in: -1...5)
        
        let x = randomRadius * cos(randomAngle)
        let y = randomY
        let z = randomRadius * sin(randomAngle)
        
        return SCNVector3(x, y, z)
    }
    
    
    private func loadAndPlace3dModel() {
        
        setupScene()
        
        DispatchQueue.global(qos: .background).async {
            self.startRandomlyPlacingModels()
        }
    }
    
    
    private func startRandomlyPlacingModels() {
        for _ in 0..<maxBubbleCount {
            DispatchQueue.global(qos: .background).async {
                self.placeBubbleModel()
            }
        }
        
        for _ in 0..<30 {
            DispatchQueue.global(qos: .background).async {
                self.placeBannerFish()
            }
        }

        for _ in 0..<20 {
            DispatchQueue.global(qos: .background).async {
                self.placeClownfish()
            }
            DispatchQueue.global(qos: .background).async {
                self.placeAngelFish()
            }
            DispatchQueue.global(qos: .background).async {
                self.placeDoubleSaddle()
            }
            DispatchQueue.global(qos: .background).async {
                self.placeyellowTang()
            }
        }
    }

    private func placeBubbleModel() {
        DispatchQueue.main.async {
            let distance = Float.random(in: 0...20)
            let angle = Float.random(in: 0...(2 * Float.pi))
            let x = distance * cos(angle)
            let z = distance * sin(angle)
            let y = Float.random(in: 0.0...3.0)
            
            guard let modelNode = MarineLife3DModel.fromGLB(modelName: Configs.ModelNames.bubble)?.getNode() else { return }
            
            let position = SCNVector3(x, y, z)
            modelNode.scale = SCNVector3(x: 2.0, y: 2.0, z: 2.0)
            modelNode.position = position
            
            self.arView.scene.rootNode.addChildNode(modelNode)
        }
    }

    private func placeBannerFish() {
        DispatchQueue.main.async {
            let distance = Float.random(in: 0...25)
            let angle = Float.random(in: 0...(2 * Float.pi))
            let x = distance * cos(angle)
            let z = distance * sin(angle)
            let y = Float.random(in: 0.0...4.0)
            
            guard let modelNode = MarineLife3DModel.fromSCN(modelName: Configs.ModelNames.bannerfish)?.getNode() else { return }
            
            let position = SCNVector3(x, y, z)
            modelNode.position = position
            modelNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
            let rotateAction = SCNAction.rotateBy(x: 0, y:  -(.pi / 2), z: 0, duration: 3.0)
            self.arView.scene.rootNode.addChildNode(modelNode)
            self.moveNodeToTargetAndBack(node: modelNode, targetPosition: SCNVector3(x: modelNode.position.x, y: modelNode.position.y, z: 3), addAction: rotateAction, duration: 20, rotateDuration: 3)
        }
    }

    private func placeyellowTang() {
        DispatchQueue.main.async {
            let distance = Float.random(in: 10...20)
            let angle = Float.random(in: 0...(2 * Float.pi))
            let x = distance * cos(angle)
            let z = distance * sin(angle)
            let y = Float.random(in: -1.0...3.0)
            
            guard let modelNode = MarineLife3DModel.fromSCN(modelName: Configs.ModelNames.yellowTang)?.getNode() else { return }
            let position = SCNVector3(x, y, z)
            modelNode.position = position
            modelNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
            let rotateAction = SCNAction.rotateBy(x: 0, y:  (.pi / 4), z: 0, duration: 1.0)
            self.arView.scene.rootNode.addChildNode(modelNode)
            self.moveNodeToTargetAndBack(node: modelNode, targetPosition: SCNVector3(x: modelNode.position.x, y: modelNode.position.y, z: 8), addAction: rotateAction, duration: 10, rotateDuration: 3)
        }
    }

    private func placeAngelFish() {
        DispatchQueue.main.async {
            let distance = Float.random(in: 0...20)
            let angle = Float.random(in: 0...(2 * Float.pi))
            let x = distance * cos(angle)
            let z = distance * sin(angle)
            let y = Float.random(in: -1.0...1.0)
            
            guard let modelNode = MarineLife3DModel.fromSCN(modelName: Configs.ModelNames.angelfish)?.getNode() else { return }
            
            let position = SCNVector3(x, y, z)
            modelNode.position = position
            modelNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
            self.arView.scene.rootNode.addChildNode(modelNode)
        }
    }

    private func placeDoubleSaddle() {
        DispatchQueue.main.async {
            let distance = Float.random(in: 10...20)
            let angle = Float.random(in: 0...(2 * Float.pi))
            let x = distance * cos(angle)
            let z = distance * sin(angle)
            let y = Float.random(in: 1.0...3.0)
            
            guard let modelNode = MarineLife3DModel.fromSCN(modelName: Configs.ModelNames.caranx)?.getNode() else { return }
            
            let position = SCNVector3(x, y, z)
            modelNode.position = position
            self.arView.scene.rootNode.addChildNode(modelNode)
        }
    }

    private func placeClownfish() {
        DispatchQueue.main.async {
            let distance = Float.random(in: 0...25)
            let angle = Float.random(in: 0...(2 * Float.pi))
            let x = distance * cos(angle)
            let z = distance * sin(angle)
            let y = Float.random(in: -1.0...1.0)
            
            guard let modelNode = MarineLife3DModel.fromSCN(modelName: Configs.ModelNames.clownfish)?.getNode() else { return }
            
            let position = SCNVector3(x, y, z)
            modelNode.position = position
            self.arView.scene.rootNode.addChildNode(modelNode)
        }
    }

    
    private func createTaiangleNode(with name: String) -> SCNNode {
        let triangleNode = SCNNode()
        
        guard let model1 = MarineLife3DModel.fromGLB(modelName: name)?.getNode(),
              let model2 = MarineLife3DModel.fromGLB(modelName: name)?.getNode(),
              let model3 = MarineLife3DModel.fromGLB(modelName: name)?.getNode() else {
            return triangleNode
        }
        
        let scale = SCNVector3(0.1, 0.1, 0.1)
        
        model1.position = SCNVector3(x: 0, y: 0, z: 0)
        model1.scale = scale
        model2.position = SCNVector3(x: 3, y: 0, z: 0)
        model2.scale = scale
        model3.position = SCNVector3(x: 2, y: 3, z: 0)
        model3.scale = scale
        
        triangleNode.addChildNode(model1)
        triangleNode.addChildNode(model2)
        triangleNode.addChildNode(model3)
        
        return triangleNode
    }
    
    func rotateModelAroundCenter(modelNode: SCNNode, clockwise: Bool) {
        let rotationDuration: TimeInterval = 5000.0
        let rotationAngle = clockwise ? -2 * Float.pi : 2 * Float.pi

        SCNTransaction.begin()
        SCNTransaction.animationDuration = rotationDuration
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .linear)

        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(rotationAngle), z: 0, duration: rotationDuration)
        let repeatAction = SCNAction.repeatForever(rotationAction)

        modelNode.runAction(repeatAction)

        SCNTransaction.commit()
    }
    

    func moveNodeBackAndForth(node: SCNNode, destinationPoint: SCNVector3, duration: TimeInterval) {
        let moveAction = SCNAction.move(to: destinationPoint, duration: duration)
        let moveBackAction = SCNAction.move(to: node.position, duration: duration)
        let sequenceAction = SCNAction.sequence([moveAction, moveBackAction])
        let repeatAction = SCNAction.repeatForever(sequenceAction)
        
        node.runAction(repeatAction)
    }
    
    func moveNodeToTargetAndBack(node: SCNNode, targetPosition: SCNVector3, addAction: SCNAction?, duration: TimeInterval, rotateDuration: TimeInterval) {
        
        let moveAction = SCNAction.move(to: targetPosition, duration: duration)
        let reverseMoveAction = SCNAction.move(to: node.position, duration: duration)
        let rotateAction = SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: rotateDuration)
        let sequenceAction = SCNAction.sequence([addAction ?? SCNAction() ,moveAction, rotateAction, reverseMoveAction, rotateAction])
        let repeatAction = SCNAction.repeatForever(sequenceAction)
        
        node.runAction(repeatAction)
    }
}



extension AquariumViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("DidAdd: \(node)")
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("ARDelegate:\(#function)")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("ARDelegate:\(#function)")
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print("ARSessionDelegate:\(#function)")
    }
}




