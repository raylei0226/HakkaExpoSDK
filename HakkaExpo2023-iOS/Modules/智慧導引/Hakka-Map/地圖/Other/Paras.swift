//
//  Para.swift

import Foundation

struct Paras {
    static let telNumber = URL(string: "tel://1999")!
    static let indoorApiKey = "ad150a79-dd1d-4535-b806-25e3c92a8b7b"
    static let indoorApiSecret = "1vb7Cn5OqGZPcnnYlC5CyRR1PVU83Qi5iDu1BFVIbsBo5h9J/AeDGqIknvL7QlpKxLvY5zRzvGNSWRCOS6YGDc6ZqKmS6Jel/N8sZMLshh4HLQhGjO6wU0fN+nSA9g=="
    static let walkGap = 1.0
    static let stepTime = 0.25
    static let reachTargetText = "已抵達目的地"
    static let nextFloorText = "請前往"
    static let mapTopPadding:CGFloat = 60
    static let positioningText = "定位中..."
    static let processingText = "處理中..."
    static let locateBtnBottom:CGFloat = 50

    static let platform = "ios"
    static let guideDistance = 4.0
    static let arrowDistance = 10.0
    static let certainty:Double = 0.8
    static let standardCertainty:Double = 0.8
    static let standardAccuracy:Double = 20
    static let arrowPendingLimit = 5
    static let initZoom:Float = 19
    static let lock = true
    
    static let offsetDistance: Double! = 8 //偏離距離
    static let offsetTime: Double! = 8 //偏離時間
    static let offsetMsg = "您似乎偏離導引路線太遠囉，是否要為您重新規劃路線？" //偏離提示
    static let kMapStyle = "[" +
      "{" +
      "  \"featureType\": \"administrative.land_parcel\"," +
      "  \"elementType\": \"labels\"," +
      "  \"stylers\": [" +
      "    {" +
      "      \"visibility\": \"off\"" +
      "    }" +
      "  ]" +
      "}," +
      "{" +
      "  \"featureType\": \"poi\"," +
      "  \"elementType\": \"labels.text\"," +
      "  \"stylers\": [" +
      "    {" +
      "      \"visibility\": \"off\"" +
      "    }" +
      "  ]" +
      "}," +
      "{" +
      "  \"featureType\": \"poi.business\"," +
      "  \"stylers\": [" +
      "    {" +
      "      \"visibility\": \"off\"" +
      "    }" +
      "  ]" +
      "}," +
      "{" +
      "  \"featureType\": \"road\"," +
      "  \"elementType\": \"labels.icon\"," +
      "  \"stylers\": [" +
      "    {" +
      "      \"visibility\": \"off\"" +
      "    }" +
      "  ]" +
      "}," +
      "{" +
      "  \"featureType\": \"road.local\"," +
      "  \"elementType\": \"labels\"," +
      "  \"stylers\": [" +
      "    {" +
      "      \"visibility\": \"off\"" +
      "    }" +
      "  ]" +
      "}," +
      "{" +
      "  \"featureType\": \"transit\"," +
      "  \"stylers\": [" +
      "    {" +
      "      \"visibility\": \"off\"" +
      "    }" +
      "  ]" +
      "}" +
    "]"
}
