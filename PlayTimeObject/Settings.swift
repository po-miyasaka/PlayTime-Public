//
//  User.swift
//  playTime
//
//  Created by miyasakakazutoshi on 2018/02/23Friday.
//  Copyright © 2018 po-miyasaka. All rights reserved.
//

import Foundation
import UIKit
import Utilities

public struct UUID {
    public let value: String
    public init(value: String) {
        self.value = value
    }
    public static func defaultValue() -> UUID {
        return UUID(value: NSUUID().uuidString)
    }
}




public struct Build {
    public let value: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String // swiftlint:disable:this force_cast
    public init() {}
}

public struct RStatus: Codable {
    public var rNumber: String
    public var shouldShowBackup: Bool
    public var shouldAboutApp: Bool
    public var shouldShowTshirt: Bool

    public  enum CodingKeys: String, CodingKey {
        case rNumber = "r"
        case shouldShowBackup = "sb"
        case shouldAboutApp = "aa"
        case shouldShowTshirt = "st"
    }

    public func isR(with build: Build = Build()) -> Bool {
        return rNumber == build.value
    }

}

public enum SortType: Int{
    case created = 0
    case latest
    case frequency

    public var displayText: String {
        switch self {
        case.created:
            return "registedOrder".localized
        case.latest:
            return "updatedOrder".localized
        case .frequency:
            return "frequencyOrder".localized
        }
    }

   

    public static func defaultValue() -> SortType {
        return SortType.latest
    }

}



public struct ExplorerStatus: OptionSet {
    public static func defaultValue() -> ExplorerStatus {
        return ExplorerStatus(rawValue: 0)
    }

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let launched = ExplorerStatus(rawValue: 1)
    public static let addedQuest = ExplorerStatus(rawValue: 1 << 1)
    public static let tutorialShown = ExplorerStatus(rawValue: 1 << 2)
    public static let logined = ExplorerStatus(rawValue: 1 << 3)
    public static let backuped = ExplorerStatus(rawValue: 1 << 4)
    public static let finishedQuest = ExplorerStatus(rawValue: 1 << 5)
    public static let graghShown = ExplorerStatus(rawValue: 1 << 6)
    public static let timeLeaper = ExplorerStatus(rawValue: 1 << 7)
    public static let dragonShown = ExplorerStatus(rawValue: 1 << 8)
    public static let shouldSaveDefaultStories = ExplorerStatus(rawValue: 1 << 9)
}

