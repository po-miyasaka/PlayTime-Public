//
//  RealmObject.swift
//  DataStore
//
//  Created by kazutoshi miyasaka on 2019/08/03.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RealmSwift
import Utilities

//public class StoryData: Object, IDStringToDate {
//    @objc dynamic public var title: String?
//    @objc dynamic public var createdID: String?
//    @objc dynamic public var isDeleted: Bool = false
//    override static public func primaryKey() -> String? {
//        return "createdID"
//    }
//}
//
//public class QuestData: Object, IDStringToDate {
//    @objc dynamic public var title: String?
//    @objc dynamic public var deleted: Bool = false
//    @objc dynamic public var createdID: String?
//    @objc dynamic public var activeTime: Date?
//    @objc dynamic public var limitTime: TimeInterval = 60 * 25 * 1
//    @objc dynamic public var isNotify: Bool = false
//    @objc dynamic public var dragonName: Int = 0
//    @objc dynamic public var storyData: StoryData?
//    
//    public var meanTimesData = List<MeanTimeData>()
//    public var commentsData = List<CommentData>()
//    
//    override static public func primaryKey() -> String? {
//        return "createdID"
//    }
//}
//
//public class MeanTimeData: Object {
//    @objc dynamic public var start: Date?
//    @objc dynamic public var end: Date?
//    @objc dynamic public var isValid: Int = 0
//    @objc dynamic public var dragon: Int = 0
//}
//
//public class CommentData: Object, IDStringToDate {
//    @objc dynamic public var expression: String?
//    @objc dynamic public var createdID: String?
//    @objc dynamic public var type: Int = 0
//    @objc dynamic public var isDeleted: Bool = false
//    
//    override static public func primaryKey() -> String? {
//        return "createdID"
//    }
//}
//
//
//public class SortTypeData: Object {
//    @objc dynamic public var primaryKey: String = "primary"
//    @objc dynamic public var statusInt: Int = 0
//    override static public func primaryKey() -> String? {
//        return "primaryKey"
//    }
//}
//
//public class ExplorerStatusData: Object {
//    @objc dynamic public var statusInt: Int = 0
//    @objc dynamic public var primaryKey: String = "primary"
//    override static public func primaryKey() -> String? {
//        return "primaryKey"
//    }
//}
//
//public class UUIDData: Object {
//    @objc dynamic public var uuid: String = ""
//    @objc dynamic public var primaryKey: String = "primary"
//    override static public func primaryKey() -> String? {
//        return "primaryKey"
//    }
//}
//
//
//public protocol IDStringToDate: NSObject {
//    var createdID: String? { get }
//}
//
//public extension IDStringToDate {
//    func getIDDate() -> Date? {
//        guard let idString = createdID else { return nil }
//        return DateUtil.full.formatter.date(from: idString)
//    }
//}
//
