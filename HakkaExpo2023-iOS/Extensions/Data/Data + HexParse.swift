//
//  Data + HexParse.swift
//  HakkaExpo2023-iOS
//
//  Created by 雷承宇 on 2023/6/28.
//

extension Data {
    func hexParse() -> Int {
        let dataString =  self.compactMap { String(format: "%02x", $0).uppercased() }.joined(separator: "")
        var sum = 0
        let str = dataString.uppercased()
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }
}

//data轉16進制
extension Data {
    func hexString() -> String {
        return self.compactMap { String(format: "%02x", $0).uppercased() }.joined(separator: "")
    }
}

extension String{
    func changeToInt(num:String) -> Int {
        let str = num.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }
}
