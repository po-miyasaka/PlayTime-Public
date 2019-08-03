//
//  Color.swift
//  PlayTime
//
//  Created by kazutoshi miyasaka on 2019/07/29.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import UIKit

public enum Colors {
    case backgroundLightClearBlack
    case backgroundDarkClearBlack
    case backgroundWhite
    case mainGold

    public var uiColor: UIColor {
        switch self {
        case .backgroundLightClearBlack:
            return .init(red: 0, green: 0, blue: 0, alpha: 0.5)
        case .backgroundDarkClearBlack:
            return .init(red: 0, green: 0, blue: 0, alpha: 0.5)
        case .backgroundWhite:
            return .init(red: 254, green: 254, blue: 254, alpha: 0.5)
        case .mainGold:
            return UIColor(hexString: "CFBC0A")
        }
    }
}
