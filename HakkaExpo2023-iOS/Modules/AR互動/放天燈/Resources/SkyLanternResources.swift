//
//  SkyLanternResources.swift
//  OmniArTaipei
//
//  Created by Dong on 2022/12/6.
//

import Foundation
import UIKit
import GLTFSceneKit

extension Notification.Name {
    static let didSkyLanternResourcesUpdate = Notification.Name("didSkyLanternResourcesUpdate")
}

class SkyLanternResources {
    static let shared = SkyLanternResources()
    static var isReady = false
    static var firePathUrl: URL?
    static var materialPath: String?
    
    private let domainName = "https://omnig-test01.omniguider.com/hakkaexpoARFile/"
    private let fontFileName = "calligraphy.ttc"
    private let fireFileName = "SkyLantern_Fire.png"
    private let materialFileName = "SkyLantern_Texture.jpg"
    private let modelFileName = "SkyLantern.glb"
    
    private let folderName = "Omni_AR_SkyLantern"
    private let customFontName = "DFLungMen-W9-WIN-BF"
    
    private let isUseLocalData = false
    
    func setup() {
        if isUseLocalData {
            setFontByLocal()
            setFirePathUrlByLocal()
            setMaterialPathByLocal()
            SkyLanternResources.isReady = true
        }else {
            guard createFolderIfNeed() else {
                assertionFailure("Create Folder Fail")
                return
            }
            setFont()
            setFirePathUrl()
            setMaterialPath()
        }
    }
    
    private func updateStatusIfNeed() {
        if
            isFontExist(),
            SkyLanternResources.firePathUrl != nil,
            SkyLanternResources.materialPath != nil
        {
            SkyLanternResources.isReady = true
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didSkyLanternResourcesUpdate, object: nil)
            }
        }
    }
    
    private func createFolderIfNeed() -> Bool {
        
        let folderPath = NSTemporaryDirectory() + folderName
        guard !FileManager.default.fileExists(atPath: folderPath) else {return true}
        
        do {
            
            try FileManager.default.createDirectory( atPath: folderPath, withIntermediateDirectories: true )
            return true
            
        } catch {
            
            print(error.localizedDescription)
            return false
        }
    }
}

//MARK: - Font
extension SkyLanternResources {
    func getFont() -> UIFont {
        if let font = UIFont(name: customFontName, size: 85) {
            return font
        }else {
            return .boldSystemFont(ofSize: 85)
        }
    }
    
    private var fontFilePath: String {
        return NSTemporaryDirectory() + folderName + "/" + fontFileName
    }
    
    private func isFontExist() -> Bool {
        var isExist = false
        UIFont.familyNames.forEach({familyName in
            UIFont.fontNames(forFamilyName: familyName).forEach({fontName in
                if fontName == customFontName {
                    isExist = true
                }
            })
        })
        return isExist
    }
    
    private func downloadAndSaveFontFile() {
        
        guard let url = URL(string: domainName + fontFileName) else {return}
        URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            guard let data else {
                if let error {
                    print(error.localizedDescription)
                }
                return
            }
            let bufferData = NSMutableData(data: data)
            if bufferData.write(toFile: self.fontFilePath, atomically: true) {
                self.addFontFromFile()
            }
        }).resume()
    }
    
    private func addFontFromFile() {
        let url = URL(fileURLWithPath: fontFilePath)
        guard
            let data = try? Data(contentsOf: url),
            let dataProvider = CGDataProvider(data: data as CFData),
            let fontRef = CGFont(dataProvider),
            CTFontManagerRegisterGraphicsFont(fontRef, nil)
        else {
            print("Add Font Fail")
            return
        }
        updateStatusIfNeed()
    }
    
    private func setFont() {
        if isFontExist() {
            updateStatusIfNeed()
        }else if FileManager.default.fileExists(atPath: fontFilePath) {
            addFontFromFile()
        }else {
            downloadAndSaveFontFile()
        }
    }
    
    private func setFontByLocal() {
        guard !isFontExist() else {return}
        let bundle = Bundle(for: SkyLanternResources.self)
        guard
            let path = bundle.path(forResource: "calligraphy", ofType: "ttc"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let dataProvider = CGDataProvider(data: data as CFData),
            let fontRef = CGFont(dataProvider),
            CTFontManagerRegisterGraphicsFont(fontRef, nil)
        else {return}
    }
}

//MARK: - Fire
extension SkyLanternResources {
    private func setFirePathUrlByLocal() {
        let bundle = Bundle(for: SkyLanternResources.self)
        guard let path = bundle.path(forResource: "TaipeiSkyLamp_Fire_v1", ofType: "png") else {return}
        SkyLanternResources.firePathUrl = URL(fileURLWithPath: path)
    }
    
    private func setFirePathUrl() {
        if FileManager.default.fileExists(atPath: fireFilePath) {
            SkyLanternResources.firePathUrl = URL(fileURLWithPath: fireFilePath)
            updateStatusIfNeed()
        }else {
            downloadAndSaveFireFile()
        }
    }
    
    private func downloadAndSaveFireFile() {
        guard let url = URL(string: domainName + fireFileName) else {return}
        URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            guard let data else {
                if let error {
                    print(error.localizedDescription)
                }
                return
            }
            let bufferData = NSMutableData(data: data)
            if bufferData.write(toFile: self.fireFilePath, atomically: true) {
                SkyLanternResources.firePathUrl = URL(fileURLWithPath: self.fireFilePath)
                self.updateStatusIfNeed()
            }
        }).resume()
    }
    
    private var fireFilePath: String {
        return NSTemporaryDirectory() + folderName + "/" + fireFileName
    }
}

//MARK: - Material
extension SkyLanternResources {
    private func setMaterialPathByLocal() {
        let bundle = Bundle(for: SkyLanternResources.self)
        guard let path = bundle.path(forResource: "SKyLamp", ofType: "jpg") else {return}
        SkyLanternResources.materialPath = path
    }
    
    private func setMaterialPath() {
        if FileManager.default.fileExists(atPath: materialFilePath) {
            SkyLanternResources.materialPath = materialFilePath
            updateStatusIfNeed()
        }else {
            downloadAndSaveMaterialFile()
        }
    }
    
    private func downloadAndSaveMaterialFile() {
        guard let url = URL(string: domainName + materialFileName) else {return}
        URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            guard let data else {
                if let error {
                    print(error.localizedDescription)
                }
                return
            }
            let bufferData = NSMutableData(data: data)
            if bufferData.write(toFile: self.materialFilePath, atomically: true) {
                SkyLanternResources.materialPath = self.materialFilePath
                self.updateStatusIfNeed()
            }
        }).resume()
    }
    
    private var materialFilePath: String {
        return NSTemporaryDirectory() + folderName + "/" + materialFileName
    }
}

//MARK: - Model
extension SkyLanternResources {
    func getSceneSource() -> GLTFSceneSource? {
        if isUseLocalData {
            let bundle = Bundle(for: SkyLanternResources.self)
            guard
                let path = bundle.path(forResource: "TaipeiSkyLamp_v2", ofType: "glb"),
                let sceneSource = try? GLTFSceneSource(path: path)
            else {return nil}
            return sceneSource
        }else {
            guard let url = URL(string: domainName + modelFileName) else {return nil}
            return GLTFSceneSource(url: url)
        }
    }
}
