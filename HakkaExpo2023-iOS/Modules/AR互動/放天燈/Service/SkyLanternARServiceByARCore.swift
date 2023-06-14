import Foundation
import ARKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import ARCoreGeospatial
import ARCoreGARSession
import GLTFSceneKit
import MapKit

class SkyLanternARServiceByARCore: NSObject, SkyLanternARService {
    
    enum LocalizationState: Int {
        case pretracking = 0
        case localizing = 1
        case localized = 2
        case failed = -1
    }

    private var userImage: UIImage!

    private var firebaseReference: DatabaseReference!
    private var firebaseStorageReference: StorageReference!
    private var firebaseAnchorResult: FirebaseOmniAnchorModel!
    private var firebaseNextShortCode: Int!

    private var garSession: GARSession?
    private let garSession_APIKey = "AIzaSyDg_0j0HxK-CNlL00Ovx6BVhCIpGzzUXvs"
    private var garFrame: GARFrame!

    private var sceneView = ARSCNView()
    private var scene: SCNScene!
    private var arSession: ARSession!

    private var localizationState: LocalizationState!
    private var lastStartLocalizationDate: Date!
    private let kLocalizationFailureTime: TimeInterval = 3 * 60
    private let kHorizontalAccuracyLowThreshold: CLLocationAccuracy = 10
    private let kHorizontalAccuracyHighThreshold: CLLocationAccuracy = 20
    private let kHeadingAccuracyLowThreshold: CLLocationDirectionAccuracy = 15
    private let kHeadingAccuracyHighThreshold: CLLocationDirectionAccuracy = 25

    typealias FirebaseAnchorShortKey = String
    typealias FirebaseAnchorIdentifier = String
    private var maxFirebaseAnchor = 15
    private var maxDistanceFirebaseAnchor: CLLocationDistance = 20
    private var addedFirebaseAnchors = [FirebaseAnchorShortKey: FirebaseAnchorIdentifier]()
    private var addedNodes = [String]()

    private var currentHeading: CLLocationDirection = 0
    private var userDevicePosition: SCNVector3 = SCNVector3(0, 0, 0)
    private var userDeviceEulerAnglesY: Float = 0
    private var userNode: SkyLanternNode!
    private var userCoordinate: CLLocationCoordinate2D!
    private var userShortKey: String!

    //Debug
    private let isTestNode = false
    private let isTestFirebaseNode = false
    private var debugTrackingLabel: UILabel?
    private var debugStatusLabel: UILabel?
    private var debugTrackingView: DebugTrackingView?
    private var isStressTesting = false
    private var stressTestingLabel: UILabel?
    private var memoryUsedLabel: UILabel?
    private var memoryTimer: Timer?
    private var stressTestingCount = 0
    
    //MARK: - Action
    /**透過GARSession解析後的GARFrame刷新模型*/
    private func update(with frame: GARFrame) {
        garFrame = frame
        updateLocalizationState()
        updateNodes()
        updateDebugTracking()
        updateStatusLabel()
    }
    /**刷新GARSession的狀態*/
    private func updateLocalizationState() {
        guard let earth = garFrame.earth else {return}
        guard earth.earthState == .enabled else {
            localizationState = .failed
            return
        }
        guard earth.trackingState == .tracking else {
            localizationState = .pretracking
            return
        }
        let geospatialTransform = earth.cameraGeospatialTransform
        let now = Date()

        if localizationState == .pretracking {
            localizationState = .localizing
        }else if localizationState == .localizing {
            if let geospatialTransform, geospatialTransform.horizontalAccuracy <= kHorizontalAccuracyLowThreshold, geospatialTransform.headingAccuracy <= kHeadingAccuracyLowThreshold {
                localizationState = .localized
                if firebaseAnchorResult != nil {
                    addFirebaseAnchorIfNeed()
                }
            }else if now.timeIntervalSince(lastStartLocalizationDate) >= kLocalizationFailureTime {
                localizationState = .failed
            }
        }else {
            if let geospatialTransform, geospatialTransform.horizontalAccuracy > kHorizontalAccuracyHighThreshold || geospatialTransform.headingAccuracy > kHeadingAccuracyHighThreshold {
                localizationState = .localizing
                lastStartLocalizationDate = now
            }
        }
    }
    /**刷新所有模型狀態*/
    private func updateNodes() {
        guard firebaseAnchorResult != nil else {return}
        for anchor in garFrame.anchors {
            let identifier = "\(anchor.identifier)"
            guard
                anchor.trackingState == .tracking,
                let shortKey = getAddedAnchorShortKey(by: identifier)
            else {continue}
            let timestamp = firebaseAnchorResult.timestamp(at: shortKey)

            let isExpired = (Date().timeIntervalSince1970 - timestamp > SkyLanternNode.maxTime) && !isTestFirebaseNode

            if !addedNodes.contains(identifier) && !isExpired {
                let newNode = SkyLanternNode(timestamp: timestamp, isTest: isTestFirebaseNode)
                newNode.simdTransform = anchor.transform
                getImageFromStorage(with: shortKey, node: newNode)
                scene.rootNode.addChildNode(newNode)
                addedNodes.append(identifier)
            }else if addedNodes.contains(identifier) && isExpired {
                addedNodes.removeAll(where: {$0 == identifier})
            }
        }
    }
    /**透過錨點的Identifier取得對應的ShortKey*/
    private func getAddedAnchorShortKey(by identifier: String) -> String? {
        var key: String?
        for info in addedFirebaseAnchors {
            if info.value == identifier {
                key = info.key
            }
        }
        return key
    }
    /**設置GARSession*/
    private func setupGARSession() {
        
        guard garSession == nil else {return}
        do {
            garSession = try GARSession(apiKey: garSession_APIKey, bundleIdentifier: nil)
        }catch {
            updateDebugStatus("Failed to create GARSession: \(error.localizedDescription)")
            AlertManager.showAlert(in: AlertManager.topViewController()!, message: "Failed to create GARSession: \(error.localizedDescription)")
            return
        }

        guard let garSession, garSession.isGeospatialModeSupported(.enabled) else {
            updateDebugStatus("GARGeospatialModeEnabled is not supported on this device.")
            AlertManager.showAlert(in: AlertManager.topViewController()!, message: "GARGeospatialModeEnabled is not supported on this device.")
            return
        }
        
        let configuration = GARSessionConfiguration()
        configuration.geospatialMode = .enabled
        var error: NSError?
        garSession.setConfiguration(configuration, error: &error)
        if let error {
            updateDebugStatus("Failed to configure GARSession: \(error.localizedDescription)")
            print("Failed to configure GARSession: \(error.localizedDescription)")
            AlertManager.showAlert(in: AlertManager.topViewController()!, message: "Failed to configure GARSession: \(error.localizedDescription)")
            return
        }
        localizationState = .pretracking
        lastStartLocalizationDate = Date()
    }
    /**執行ARSession*/
    func run(_ completion: @escaping (()->())) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.planeDetection = .horizontal
        arSession.run(configuration)
        completion()
        if isTestNode {
            testNode()
        }
    }
    /**結束*/
    func stop() {
        guard let secondary = FirebaseApp.app(name: "HakkaExop") else {return}
        secondary.delete({result in
            print(result ? "Success" : "Fail")
        })
        firebaseReference = nil
        firebaseStorageReference = nil
        scene = nil
        arSession.pause()
        arSession.delegate = nil
        arSession = nil
        NotificationCenter.default.removeObserver(self)
        garSession = nil
        userNode = nil
        if memoryTimer != nil {
            memoryTimer?.invalidate()
            memoryTimer = nil
        }
    }
    /**拍照*/
    func snapshot() -> UIImage {
        sceneView.snapshot()
    }
    //MARK: - Init
    /**設置相關功能*/
    init(arView: UIView, image: UIImage, debug: Bool, stressTesting: Bool) {
        super.init()
        userImage = image
        isStressTesting = stressTesting
        setupSceneView(arView, debug: debug)
        setupFirebase()
        arSession.delegate = self
        setDatabaseObserve()
        setupGARSession()
    }

    private func setupSceneView(_ arView: UIView, debug: Bool) {
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        if debug {
            sceneView.debugOptions = .showFeaturePoints
        }
        arView.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.topAnchor.constraint(equalTo: arView.topAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: arView.bottomAnchor).isActive = true
        sceneView.leadingAnchor.constraint(equalTo: arView.leadingAnchor).isActive = true
        sceneView.trailingAnchor.constraint(equalTo: arView.trailingAnchor).isActive = true
        scene = sceneView.scene
        arSession = sceneView.session
    }

    private func setupFirebase() {
        let currentBundle = Bundle(for: SkyLanternARServiceByARCore.self)
        guard
            FirebaseApp.app(name: "HakkaExop") == nil,
            let filePath = currentBundle.path(forResource: "Hakka-GoogleService-Info", ofType: "plist"),
            let fileopts = FirebaseOptions(contentsOfFile: filePath)
        else {
            return
        }
        FirebaseApp.configure(name: "HakkaExop", options: fileopts)

        guard let secondary = FirebaseApp.app(name: "HakkaExop") else {
            return
        }
        firebaseReference = Database.database(app: secondary).reference()
        firebaseStorageReference = Storage.storage(app: secondary).reference()
    }
}

//MARK: - ARSession Delegate
extension SkyLanternARServiceByARCore: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let setX = frame.camera.transform.columns.3.x
        let setY = frame.camera.transform.columns.3.y
        let setZ = frame.camera.transform.columns.3.z
        userDevicePosition = SCNVector3(setX, setY, setZ)
        userDeviceEulerAnglesY = frame.camera.eulerAngles.y
        guard
            let garSession,
            let garFrame = try? garSession.update(frame),
            localizationState != .failed
        else {return}
        update(with: garFrame)
    }
}

//MARK: - LocationService
extension SkyLanternARServiceByARCore {
    func addNotificationService() {
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLocation), name: .didUpdateLocation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateHeading), name: .didUpdateHeading, object: nil)
    }
    
    @objc private func didUpdateLocation() {
        guard let location = LocationService.location else {return}
        if let garSession {
            garSession.checkVPSAvailability(coordinate: location.coordinate, completionHandler: {availability in
                if availability != .available {
                    AlertManager.showAlert(in: AlertManager.topViewController()!, title: "VPS not available", message: "Your current location does not have VPS coverage. Your session will be using your GPS signal only if VPS is not available.")
               
                }
            })
        }else {
            AlertManager.showAlert(in: AlertManager.topViewController()!, message: "GARSession is nil.")
        }
    }
    
    @objc private func didUpdateHeading() {
        guard let heading = LocationService.heading else {return}
        currentHeading = heading
    }
}

//MARK: - User SkyLantern
extension SkyLanternARServiceByARCore {
    /**擺放天燈*/
    func putSkyLantern() -> Bool {
        guard
            let garFrame,
            let earth = garFrame.earth,
            let camera = earth.cameraGeospatialTransform
        else {return false}
        let coordinate = camera.coordinate
        if isStressTesting {
            let node = SkyLanternNode(userImage: userImage)
            node.position = getUserSkyLanternPosition()
            node.eulerAngles.y = userDeviceEulerAnglesY
            scene.rootNode.addChildNode(node)
            updateStressTestingLabel()
        }else if userNode == nil {
            userNode = SkyLanternNode(userImage: userImage)
            userCoordinate = coordinates(startingCoordinates: coordinate, atDistance: 2, atAngle: currentHeading)
            userNode.position = getUserSkyLanternPosition()
            userNode.eulerAngles.y = userDeviceEulerAnglesY
            scene.rootNode.addChildNode(userNode)
            return true
        }
        return false
    }
    
//    private func getUserSkyLanternPosition() -> SCNVector3 {
//
//        var anglesY = userDeviceEulerAnglesY
//        if anglesY < 0 {
//            anglesY = abs(anglesY)
//        }else if anglesY > 0 {
//            anglesY = .pi + .pi - anglesY
//        }
//
//
//        let originX = userDevicePosition.x
//        let originZ = userDevicePosition.z
//        let newX = originX + 2 * cos(anglesY - .pi / 2)
//        let newZ = originZ + 2 * sin(anglesY - .pi / 2)
//
//        return SCNVector3(newX, userDevicePosition.y, newZ)
//    }
    
    //20230425
    private func getUserSkyLanternPosition() -> SCNVector3 {
        
        var anglesY = userDeviceEulerAnglesY
        
        anglesY = anglesY < 0 ? abs(anglesY) : (.pi + .pi - anglesY)
    
        let originX = userDevicePosition.x
        let originZ = userDevicePosition.z
        let distance = 2.0
        let newX = originX + Float(distance) * cos(anglesY - .pi / 2)
        let newZ = originZ + Float(distance) * sin(anglesY - .pi / 2)
        
        return SCNVector3(x: newX, y: userDevicePosition.y, z: newZ)
    }
    
    
    
    /**施放天燈*/
    func castSkyLantern() -> Bool {
        guard
            let userNode,
            let userCoordinate,
            let userImage,
            let next_short_code = firebaseNextShortCode,
            !isStressTesting
        else {
            AlertManager.showAlert(in: AlertManager.topViewController()!, message: "Cast Fail.")
            return false
        }
        let now = Date().timeIntervalSince1970
        userShortKey = "\(next_short_code + 1)"
        saveAnchor(shortKey: userShortKey, coordinate: userCoordinate, timeInterval: now)
        uploadImageToStorage(with: userShortKey, image: userImage, completion: {result in
            if result {
                print("Success")
            }else {
                print("Fail")
            }
        })
        userNode.runActionByUser()
        return true
    }
}

//MARK: - Firebase Database
extension SkyLanternARServiceByARCore {
    /**設置Firebase Database監聽*/
    private func setDatabaseObserve() {
        if isStressTesting {return}
        firebaseReference.child("omni_geo").child("anchor").observe(.value, with: {snapshot in
            guard let snapshotDic = snapshot.value as? [String: Any] else {return}
            self.firebaseAnchorResult = FirebaseOmniAnchorModel(snapshotDic)
            self.addFirebaseAnchorIfNeed()
        })
        firebaseReference.child("omni_geo").child("next_short_code").observe(.value, with: {snapshot in
            if let snapshortValue = snapshot.value as? Int {
                self.firebaseNextShortCode = snapshortValue
            }else if let snapshortValue = snapshot.value as? String {
                self.firebaseNextShortCode = Int(snapshortValue)
            }
        })
    }
    /**儲存錨點資訊至Firebase Database*/
    private func saveAnchor(shortKey: String, coordinate: CLLocationCoordinate2D, timeInterval: TimeInterval) {
        let value: [String: Any] = [
            "shortKey": shortKey,
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "source": "iOS",
            "timestamp": Int(timeInterval * 1000)]
        firebaseReference.child("omni_geo").child("anchor").child(shortKey).setValue(value)
        firebaseReference.child("omni_geo").child("next_short_code").setValue(Int(shortKey))
    }
}

//MARK: - Firebase Storage
extension SkyLanternARServiceByARCore {
    /**透過ShortKey至Firebase Storage取得天燈材質*/
    private func getImageFromStorage(with shortKey: String, node: SkyLanternNode) {
        let storageRef = firebaseStorageReference.child("images/\(shortKey).png")
        let maxSize: Int64 = 10 * 1024 * 1024
        storageRef.getData(maxSize: maxSize, completion: {data, error in
            if let error {
                print(error.localizedDescription)
            }else if let data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    node.updateMaterial(with: image)
                }
            }
        })
    }
    /**依照ShortKey上傳天燈材質至Firebase Storage*/
    private func uploadImageToStorage(with shortKey: String, image: UIImage, completion: @escaping ((Bool)->())) {
        guard
            let imageData = image.pngData()
        else {
            completion(false)
            return
        }

        let storageRef = firebaseStorageReference.child("images/\(shortKey).png")
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        storageRef.putData(imageData, metadata: metadata, completion: {result, error in
            if let error {
                print(error.localizedDescription)
                completion(false)
            }else if let result {
                print(result.size)
                completion(true)
            }
        })
    }
}

//MARK: - Anchor
extension SkyLanternARServiceByARCore {
    /**檢查並添加Firebase Database的錨點*/
    private func addFirebaseAnchorIfNeed() {
        for key in firebaseAnchorResult.anchor.keys {
            guard
                let anchorInfo = firebaseAnchorResult.anchor[key],
                !addedFirebaseAnchors.keys.contains(anchorInfo.shortKey),
                anchorInfo.shortKey != userShortKey,
                addedFirebaseAnchors.count < maxFirebaseAnchor,
                isWithinValidRange(anchorInfo.coordinate)
            else {continue}
            let eastUpSouthQTarget: simd_quatf = simd_quaternion(0.0, 0.0, 0.0, 1.0)
            addTerrainAnchor(coordinate: anchorInfo.coordinate, heading: 0, eastUpSouthQTarget: eastUpSouthQTarget, key: anchorInfo.shortKey)
        }
    }
    /**判斷Firebase Database的錨點是否在有效範圍內*/
    private func isWithinValidRange(_ coordinate: CLLocationCoordinate2D) -> Bool {
        guard
            let garFrame,
            let earth = garFrame.earth,
            let camera = earth.cameraGeospatialTransform
        else {return false}
        let userLocation = CLLocation(latitude: camera.coordinate.latitude, longitude: camera.coordinate.longitude)
        let anchorLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return userLocation.distance(from: anchorLocation) <= maxDistanceFirebaseAnchor
    }
    
    /**添加地理空間錨點**/
    private func addTerrainAnchor(coordinate: CLLocationCoordinate2D, heading: CLLocationDistance, eastUpSouthQTarget: simd_quatf, key: String) {
        guard let garSession else {return}
        let angle = Float(.pi / 180 * (180 - heading))
        let eastUpSouthQAnchor = simd_quaternion(angle, simd_make_float3(0, 1, 0))
        do {
            let anchor = try garSession.createAnchorOnTerrain(coordinate: coordinate, altitudeAboveTerrain: heading, eastUpSouthQAnchor: eastUpSouthQAnchor)
            addedFirebaseAnchors[key] = "\(anchor.identifier)"
        }catch {
            updateDebugStatus("Error adding anchor:\(error.localizedDescription)")
        }
    }
}

//MARK: - Debug
extension SkyLanternARServiceByARCore {
    //Action
    private func updateDebugStatus(_ str: String) {
        debugStatusLabel?.text = str
    }

    private func updateDebugTracking() {
        guard let garFrame, let earth = garFrame.earth else {
            debugTrackingView?.isHidden = true
            debugTrackingLabel?.isHidden = false
            debugTrackingLabel?.text = "(\(#line)):garFrame is nil"
            return
        }

        if localizationState == .failed {
            debugTrackingView?.isHidden = true
            debugTrackingLabel?.isHidden = false
            if earth.earthState != .enabled {
                debugTrackingLabel?.text = string(from: earth.earthState)
            }else {
                debugTrackingLabel?.text = "\(#line)"
            }
            return
        }

        if earth.trackingState == .paused {
            debugTrackingView?.isHidden = true
            debugTrackingLabel?.isHidden = false
            debugTrackingLabel?.text = "(\(#line)):Not tracking."
            return
        }
        guard let geospatialTransform = earth.cameraGeospatialTransform else {
            debugTrackingView?.isHidden = true
            debugTrackingLabel?.isHidden = false
            debugTrackingLabel?.text = "(\(#line)):Get earth cameraGeospatialTransform fail."
            return
        }

        debugTrackingLabel?.isHidden = true
        debugTrackingView?.isHidden = false
        debugTrackingView?.update(geospatialTransform)
    }

    private func updateStatusLabel() {
        guard let localizationState else {
            updateDebugStatus("LocalizationState is nil.")
            return
        }
        switch localizationState {
        case .localized:
            var message: String?
            for anchor in garFrame.anchors {
                if anchor.terrainState == .none {
                    continue
                }
                message = "Terrain Anchor State: \(terrainStateString(anchor.terrainState))"
            }
            if let message {
                updateDebugStatus(message)
            }
        case .pretracking:
            updateDebugStatus("Localizing your device to set anchor.")
        case .localizing:
            updateDebugStatus("Point your camera at buildings, stores, and signs near you.")
        case .failed:
            updateDebugStatus("Localization not possible.\nClose and open the app to restart.")
        }
    }

    private func terrainStateString(_ state: GARTerrainAnchorState) -> String {
        switch state {
        case .none:
            return "None"
        case .success:
            return "Success"
        case .errorInternal:
            return "ErrorInternal"
        case .taskInProgress:
            return "TaskInProgress"
        case .errorNotAuthorized:
            return "ErrorNotAuthorized"
        case .errorUnsupportedLocation:
            return "UnsupportedLocation"
        default:
            return "Unknown"
        }
    }

    private func string(from state: GAREarthState) -> String {
        switch state {
        case .errorInternal:
            return "Error Internal"
        case .errorNotAuthorized:
            return "Error Not Authorized"
        case .errorResourceExhausted:
            return "Error Resource Exhausted"
        default:
            return "Enabled"
        }
    }

    private func updateStressTestingLabel() {
        guard let stressTestingLabel else {return}
        stressTestingCount += 1
        stressTestingLabel.text = "天燈數量：\(stressTestingCount)"
    }
    
    private func startMemoryTimer() {
        guard isStressTesting else {return}
        memoryTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(memoryTimerAction), userInfo: nil, repeats: true)
    }
    
    @objc private func memoryTimerAction() {
        let report = reportMemory()
        memoryUsedLabel?.text = report.result
        memoryUsedLabel?.textColor = report.color
    }
    
    private func reportMemory() -> (result: String, color: UIColor) {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo, {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1, {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            })
        })
        var used: Float = 0
        if result == KERN_SUCCESS {
            used = Float(taskInfo.phys_footprint) / 1048576.0
        }
        let total = Float(ProcessInfo.processInfo.physicalMemory) / 1048576.0
        let rate = used / total * 100
        let usedStr = String(format: "%.1f", used)
        let totalStr = String(format: "%.1f", total)
        let rateStr = String(format: "%.2f", rate)
        let resultStr = "記憶體使用量：\(rateStr)% (\(usedStr)MB/ \(totalStr)MB)"
        var color: UIColor = .green
        if rate < 50 {
            color = .green
        }else if rate < 80 {
            color = .yellow
        }else {
            color = .red
        }
        return (resultStr, color)
    }

    //Init
    func setupDebugLabels(_ tracking: UILabel, _ status: UILabel) {
        debugTrackingLabel = tracking
        debugStatusLabel = status
    }

    func setupDebugTrackingView(_ view: DebugTrackingView) {
        debugTrackingView = view
    }

    func setupStressTestingLabel(_ stressTesting: UILabel) {
        stressTestingLabel = stressTesting
        stressTestingCount = 0
    }
    
    func setupMemoryUsedLabel(_ memoryUsed: UILabel) {
        memoryUsedLabel = memoryUsed
        startMemoryTimer()
    }
}

//MARK: - Other
extension SkyLanternARServiceByARCore {
    /**依經緯度、距離與角度，取得新的經緯度座標*/
    private func coordinates(startingCoordinates: CLLocationCoordinate2D, atDistance: Double, atAngle: Double) -> CLLocationCoordinate2D {
        let distanceRadians = atDistance / 1000 / 6371
        let bearingRadians = degreesToRadians(x: atAngle)
        let fromLatRadians = degreesToRadians(x: startingCoordinates.latitude)
        let fromLonRadians = degreesToRadians(x: startingCoordinates.longitude)

        let toLatRadians = asin(sin(fromLatRadians) * cos(distanceRadians) + cos(fromLatRadians) * sin(distanceRadians) * cos(bearingRadians))
        var toLonRadians = fromLonRadians + atan2(sin(bearingRadians) * sin(distanceRadians) * cos(fromLatRadians), cos(distanceRadians) - sin(fromLatRadians) * sin(toLatRadians));

        toLonRadians = fmod((toLonRadians + 3 * .pi), (2 * .pi)) - .pi

        let lat = radiansToDegrees(x: toLatRadians)
        let lon = radiansToDegrees(x: toLonRadians)

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    private func degreesToRadians(x: Double) -> Double {
        return .pi * x / 180.0
    }

    private func radiansToDegrees(x: Double) -> Double {
        return x * 180.0 / .pi
    }
}

//MARK: - Test
extension SkyLanternARServiceByARCore {
    private func testNode() {
        let testNode = SkyLanternNode(userImage: userImage)
        testNode.position = SCNVector3(0, 0, -2)
        scene.rootNode.addChildNode(testNode)
//        testNode.runActionByUser()
    }
}
