//
//  QRCodeScannerManager.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/17.
//
import UIKit
import AVFoundation
import SnapKit

protocol QRCodeScannerDelegate: AnyObject {
    func qrCodeScanned(result: String)
    func qrCodeScanFailed(error: Error)
}

enum ScannerError: Error {
    case noCameraAvailable
}


class QRCodeScannerManager: NSObject {
    
    private let imageView = UIImageView()
    private let boxPic = UIImage(named: "boxPic", bundle: Bundle(for: AwardInfoViewController.self))
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: QRCodeScannerDelegate?
    
    
    func startScan(in view: UIView) {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.qrCodeScanFailed(error: ScannerError.noCameraAvailable )
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            let captureSession = AVCaptureSession()
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [.qr]
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.layer.bounds
            view.layer.addSublayer(previewLayer)
            
            self.captureSession = captureSession
            self.previewLayer = previewLayer
            
            self.setupBoxPic(at: view)
            self.setupLabel(at: view)
//
            self.startSession()
            
        } catch {
            delegate?.qrCodeScanFailed(error: error)
        }
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }
    
    func stopScan() {
          captureSession?.stopRunning()
          previewLayer?.removeFromSuperlayer()
      }
    
    private func setupBoxPic(at view: UIView) {
        imageView.backgroundColor = .clear
        imageView.image = boxPic
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(imageView.snp.width)
        }
        
        let customView = CustomMaskView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        customView.backgroundColor = .clear
        view.addSubview(customView)
        customView.center = view.center
    }
    
    
    private func setupLabel(at view: UIView) {
        let infoLabel = UILabel()
        infoLabel.text = "請到世界館服務櫃檯領取"
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        infoLabel.textColor = .black
        infoLabel.backgroundColor = .white
        view.addSubview(infoLabel)
        
        infoLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(100)
        }
    }
}

extension QRCodeScannerManager: AVCaptureMetadataOutputObjectsDelegate {
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let stringValue = metadataObject.stringValue {
                delegate?.qrCodeScanned(result: stringValue)
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                captureSession?.stopRunning()
            }
        }
}
