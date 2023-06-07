//
//  SkyLanternARVC.swift
//  OmniArTaipei
//
//  Created by Dong on 2022/11/22.
//

import UIKit
import ARKit

class SkyLanternARVC: UIViewController {
    
    var userImage: UIImage?
    
    enum SkyLanternStatus {
        case prepare
        case put
        case cast
    }
    
    @IBOutlet weak var arContentView: UIView!
    @IBOutlet weak var controlBackgroundImageView: UIImageView!
    @IBOutlet weak var putBtn: UIButton!
    @IBOutlet weak var castBtn: UIButton!
    @IBOutlet weak var loadingView: UIView!
    
    //Debug
    @IBOutlet weak var debugView: UIView!
    @IBOutlet weak var debugTrackingLabel: UILabel!
    @IBOutlet weak var debugStatusLabel: UILabel!
    @IBOutlet weak var debugTrackingView: DebugTrackingView!
    @IBOutlet weak var stressTestingView: UIView!
    @IBOutlet weak var stressTestingLabel: UILabel!
    @IBOutlet weak var memoryUsedLabel: UILabel!
    @IBOutlet weak var testImageView: UIImageView!
    
    private weak var service: SkyLanternARService?
    private var currentStatus = SkyLanternStatus.prepare
    private var isPhotosBeingSaved = false
    
    private let isDebug = false
    private let isStressTesting = false

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadingView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        service?.run({
            self.loadingView.isHidden = true
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if service != nil {
            service?.stop()
            service = nil
        }
    }
    
    //MARK: - IBAction
    @IBAction func putBtnPressed(_ sender: Any) {
        if let service, service.putSkyLantern() {
            currentStatus = .put
        }else {
            AlertManager.showAlert(in: self, message: "擺放天燈失敗。")
            
        }
    }
    
    @IBAction func castBtnPressed(_ sender: Any) {
        if let service, service.castSkyLantern() {
            controlBackgroundImageView.isHidden = true
            putBtn.isHidden = true
            castBtn.isHidden = true
            currentStatus = .cast
        }else {
            AlertManager.showAlert(in: self, message: "施放天燈失敗。")
        }
    }
    
    @IBAction func cameraBtnPressed(_ sender: Any) {
        guard currentStatus == .cast, !isPhotosBeingSaved, let service else {return}
        isPhotosBeingSaved = true
        let image = service.snapshot()
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //MARK: - Action
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error {
            AlertManager.showAlert(in: self, message: error.localizedDescription)
        }else {
            AlertManager.showAlert(in: self, title: "[相片已儲存]", actions: [UIAlertAction(title: "好", style: .cancel)])
        }
        isPhotosBeingSaved = false
    }
    
    @objc private func back() {
        if currentStatus == .put {
            let alert = UIAlertController(title: "天燈正在施放中，確定要清除重製嗎?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "是", style: .default, handler: {_ in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            AlertManager.showAlert(in: self, actions: [UIAlertAction(title: "否", style: .default)])

        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Init
    private func setupViews() {
        title = "準備天燈"
        let backBtn = UIBarButtonItem(image: Asset.back.image, style: .plain, target: self, action: #selector(back))
        backBtn.tintColor = .white
        navigationItem.leftBarButtonItem = backBtn
        initSkyLanternARService()
        debugView.isHidden = !isDebug
        stressTestingView.isHidden = !isStressTesting
    }
    
    private func initSkyLanternARService() {
        guard let userImage else {return}
        let arService = SkyLanternARServiceByARCore(arView: arContentView, image: userImage, debug: isDebug, stressTesting: isStressTesting)
        arService.setupDebugLabels(debugTrackingLabel, debugStatusLabel)
        arService.setupDebugTrackingView(debugTrackingView)
        arService.setupStressTestingLabel(stressTestingLabel)
        arService.setupMemoryUsedLabel(memoryUsedLabel)
        service = arService
    }
}

