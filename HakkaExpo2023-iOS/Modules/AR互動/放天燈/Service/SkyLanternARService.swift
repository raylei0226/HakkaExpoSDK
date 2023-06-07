import Foundation
import UIKit

enum SkyLanternARServiceType {
    case byARCore
    case byARCL
}

protocol SkyLanternARService: NSObject {
    /**開始執行*/
    func run(_ completion: @escaping (()->()))
    /**停止*/
    func stop()
    /**擺放天燈*/
    func putSkyLantern() -> Bool
    /**施放天燈*/
    func castSkyLantern() -> Bool
    /**拍照*/
    func snapshot() -> UIImage
}
