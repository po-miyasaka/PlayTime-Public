//
//  User.swift
//  playTime
//
//  Created by miyasakakazutoshi on 2018/02/23Friday.
//  Copyright © 2018 po-miyasaka. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import RxSwift

protocol EntityMaker {
    associatedtype Entity
    func generate() -> Entity
}

protocol RealmDataMaker {
    associatedtype EntityData: Object, EntityMaker
    func generateData() -> List<EntityData>
    static func defaultValue() -> Self
}

struct UUID: RealmDataMaker {
    let value: String

    typealias EntityData = UUIDData
    func generateData() -> List<EntityData> {
        let result = List<EntityData>()
        let uuidData = UUIDData()
        uuidData.uuid = value
        result.append(uuidData)
        return result
    }

    static func defaultValue() -> UUID {
        return UUID(value: NSUUID().uuidString)
    }
}

class UUIDData: Object, EntityMaker {
    typealias Entity = UUID
    @objc dynamic var uuid: String = ""
    @objc dynamic var primaryKey: String = "primary"
    override static func primaryKey() -> String? {
        return "primaryKey"
    }

    func generate() -> Entity {
        return UUID(value: uuid)
    }
}

struct Build {
    let value: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String // swiftlint:disable:this force_cast
}

struct RStatus: Codable {
    var rNumber: String
    var shouldShowBackup: Bool
    var shouldAboutApp: Bool
    var shouldShowTshirt: Bool

    private enum CodingKeys: String, CodingKey {
        case rNumber = "r"
        case shouldShowBackup = "sb"
        case shouldAboutApp = "aa"
        case shouldShowTshirt = "st"
    }

    func isR(with build: Build = Build()) -> Bool {
        return rNumber == build.value
    }

}

enum SortType: Int, RealmDataMaker {
    case created = 0
    case latest
    case frequency

    var displayText: String {
        switch self {
        case.created:
            return "registedOrder".localized
        case.latest:
            return "updatedOrder".localized
        case .frequency:
            return "frequencyOrder".localized
        }
    }

    typealias EntityData = SortTypeData
    func generateData() -> List<SortTypeData> {
        let result = List<EntityData>()
        let data = EntityData()
        data.statusInt = rawValue
        result.append(data)
        return result
    }

    static func defaultValue() -> SortType {
        return SortType.latest
    }

}

class SortTypeData: Object, EntityMaker {

    @objc dynamic var primaryKey: String = "primary"
    override static func primaryKey() -> String? {
        return "primaryKey"
    }
    @objc dynamic var statusInt: Int = 0

    typealias Entity = SortType
    func generate() -> SortType {
        return SortType(rawValue: statusInt) ?? SortType.latest
    }
}

struct ExplorerStatus: OptionSet, RealmDataMaker {
    static func defaultValue() -> ExplorerStatus {
        return ExplorerStatus(rawValue: 0)
    }

    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }

    static let launched = ExplorerStatus(rawValue: 1)
    static let addedQuest = ExplorerStatus(rawValue: 1 << 1)
    static let tutorialShown = ExplorerStatus(rawValue: 1 << 2)
    static let logined = ExplorerStatus(rawValue: 1 << 3)
    static let backuped = ExplorerStatus(rawValue: 1 << 4)
    static let finishedQuest = ExplorerStatus(rawValue: 1 << 5)
    static let graghShown = ExplorerStatus(rawValue: 1 << 6)
    static let timeLeaper = ExplorerStatus(rawValue: 1 << 7)
    static let dragonShown = ExplorerStatus(rawValue: 1 << 8)
    static let shouldSaveDefaultStories = ExplorerStatus(rawValue: 1 << 9)

    typealias EntityData = ExplorerStatusData
    func generateData() -> List<EntityData> {
        let result = List<EntityData>()
        let data = ExplorerStatusData()
        data.statusInt = rawValue
        result.append(data)
        return result
    }

}

class ExplorerStatusData: Object, EntityMaker {
    typealias Entity = ExplorerStatus
    func generate() -> ExplorerStatus {
        return ExplorerStatus(rawValue: statusInt)
    }

    @objc dynamic var primaryKey: String = "primary"
    override static func primaryKey() -> String? {
        return "primaryKey"
    }
    @objc dynamic var statusInt: Int = 0
}
