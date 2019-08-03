//
//  DomainObjectDataTranslator.swift
//  Repository
//
//  Created by kazutoshi miyasaka on 2019/08/03.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import PlayTimeObject
import DataStore
import RealmSwift
import Utilities

protocol EntityMaker {
    associatedtype Entity
    func generate() -> Entity
}

protocol RealmDataMaker {
    associatedtype EntityData: Object, EntityMaker
    func generateData() -> List<EntityData>
    static func defaultValue() -> Self
}

extension Story {
    func generateData() -> StoryData {
        let result = StoryData()
        result.title = title
        result.createdID = id.getIDString()
        result.isDeleted = isDeleted
        return result
    }
}

extension Sequence where Element == Story {
    func generateData() -> List<StoryData> {
        let result = List<StoryData>()
        self.forEach { result.append($0.generateData()) }
        return result
    }
}

extension StoryData {
    func generate() -> Story? {
        guard let title = title,
            let idDate = getIDDate() else { return nil }

        return Story(title: title, id: StoryUniqueID(from: idDate), isDeleted: isDeleted)
    }
}

extension Quest {
    func generateQuestData() -> QuestData {
        let data = QuestData()
        data.title = title
        data.createdID = id.getIDString()
        data.deleted = deleted
        data.activeTime = activeDate
        data.meanTimesData = meanTimes.generateMeanTimesData()
        data.storyData = story.generateData()
        data.dragonName = dragonName.rawValue
        data.isNotify = isNotify
        data.limitTime = limitTime
        data.commentsData = comments.generateCommentsData()
        return data
    }

}

extension Sequence where Element == Quest {
    func generateQuestsData() -> List<QuestData> {
        let questDatas: [QuestData] = map {
            $0.generateQuestData()
        }

        let result = List<QuestData>()
        questDatas.forEach { result.append($0) }
        return result
    }
}

extension QuestData {
    func generateQuest() -> Quest? {
        guard let title = self.title else { return nil }
        guard let idDate = getIDDate() else { return nil }
        guard let story = storyData?.generate()  else { return nil }

        let isNotify = self.isNotify
        let dragonToRaise = Dragon.Name(rawValue: self.dragonName) ?? Dragon.Name.nii
        let limitTime = self.limitTime

        let times: [MeanTime] = self.meanTimesData.compactMap { $0.generateMeanTime() }

        let comments: [Comment] = self.commentsData.compactMap { $0.generateComment() }

        return Quest(title: title,
                     id: QuestUniqueID(from: idDate),
                     meanTimes: times,
                     activeDate: activeTime,
                     deleted: deleted,
                     limitTime: limitTime,
                     isNotify: isNotify,
                     dragonName: dragonToRaise,
                     story: story,
                     comments: comments)
    }
}

extension MeanTime {
    func generateMeanTimeData() -> MeanTimeData {
        let meanTimeData = MeanTimeData()
        meanTimeData.start = start
        meanTimeData.end = end
        meanTimeData.isValid = isValid.rawValue
        meanTimeData.dragon = dragonName.rawValue
        return meanTimeData
    }
}

extension Sequence where Element == MeanTime {
    func generateMeanTimesData() -> List<MeanTimeData> {
        let datas: [MeanTimeData] = compactMap { time in
            time.generateMeanTimeData()
        }
        let result = List<MeanTimeData>()
        datas.forEach { result.append($0) }
        return result
    }
}

extension MeanTimeData {
    func generateMeanTime() -> MeanTime? {
        guard let start = start else { return nil }
        guard let end = end else { return nil }
        guard isValid != MeanTimeStatus.injustice.rawValue else { return nil }
        let dragonName = Dragon.Name(rawValue: dragon) ?? .nii
        return MeanTime(start: start,
                        end: end,
                        isValid: MeanTimeStatus(statusInt: isValid),
                        dragonName: dragonName)
    }
}

extension Sequence where Element == Comment {
    func generateCommentsData() -> List<CommentData> {
        let commentDatas: [CommentData] = map {
            let data = CommentData()
            data.createdID = $0.id.getIDString()
            data.type = $0.type.rawValue
            data.expression = $0.expression
            data.isDeleted = $0.isDeleted
            return data
        }
        let result = List<CommentData>()
        commentDatas.forEach { result.append($0) }
        return result
    }
}

extension CommentData {
    func generateComment() -> Comment? {
        guard let expression = expression else { return  nil }
        // ここで間違えてQuestDataのgetIDDateが呼ばれてた。注意
        guard let idDate = getIDDate() else { return nil }
        guard let type = CommentType(rawValue: type) else { return nil }
        guard !isDeleted else { return nil }
        return Comment(id: CommentID(from: idDate),
                       expression: expression,
                       type: type,
                       isDeleted: false)
    }
}

extension PlayTimeObject.UUID: RealmDataMaker {
    typealias EntityData = UUIDData
    func generateData() -> List<EntityData> {
        let result = List<EntityData>()
        let uuidData = UUIDData()
        uuidData.uuid = value
        result.append(uuidData)
        return result
    }
}

extension UUIDData: EntityMaker {
    typealias Entity = PlayTimeObject.UUID
    func generate() -> Entity {
        return PlayTimeObject.UUID(value: uuid)
    }
}

extension SortType: RealmDataMaker {
    typealias EntityData = SortTypeData
    func generateData() -> List<SortTypeData> {
        let result = List<EntityData>()
        let data = EntityData()
        data.statusInt = rawValue
        result.append(data)
        return result
    }
}

extension SortTypeData: EntityMaker {
    typealias Entity = SortType
    func generate() -> SortType {
        return SortType(rawValue: statusInt) ?? SortType.latest
    }
}

extension ExplorerStatus: RealmDataMaker {
    typealias EntityData = ExplorerStatusData
    func generateData() -> List<EntityData> {
        let result = List<EntityData>()
        let data = ExplorerStatusData()
        data.statusInt = rawValue
        result.append(data)
        return result
    }

}

extension ExplorerStatusData: EntityMaker {
    typealias Entity = ExplorerStatus
    func generate() -> ExplorerStatus {
        return ExplorerStatus(rawValue: statusInt)
    }
}

public class StoryData: Object, IDStringToDate {
    @objc public dynamic var title: String?
    @objc public dynamic var createdID: String?
    @objc public dynamic var isDeleted: Bool = false
    override public static func primaryKey() -> String? {
        return "createdID"
    }
}

public class QuestData: Object, IDStringToDate {
    @objc public dynamic var title: String?
    @objc public dynamic var deleted: Bool = false
    @objc public dynamic var createdID: String?
    @objc public dynamic var activeTime: Date?
    @objc public dynamic var limitTime: TimeInterval = 60 * 25 * 1
    @objc public dynamic var isNotify: Bool = false
    @objc public dynamic var dragonName: Int = 0
    @objc public dynamic var storyData: StoryData?

    public var meanTimesData = List<MeanTimeData>()
    public var commentsData = List<CommentData>()

    override public static func primaryKey() -> String? {
        return "createdID"
    }
}

public class MeanTimeData: Object {
    @objc public dynamic var start: Date?
    @objc public dynamic var end: Date?
    @objc public dynamic var isValid: Int = 0
    @objc public dynamic var dragon: Int = 0
}

public class CommentData: Object, IDStringToDate {
    @objc public dynamic var expression: String?
    @objc public dynamic var createdID: String?
    @objc public dynamic var type: Int = 0
    @objc public dynamic var isDeleted: Bool = false

    override public static func primaryKey() -> String? {
        return "createdID"
    }
}

public class SortTypeData: Object {
    @objc public dynamic var primaryKey: String = "primary"
    @objc public dynamic var statusInt: Int = 0
    override public static func primaryKey() -> String? {
        return "primaryKey"
    }
}

public class ExplorerStatusData: Object {
    @objc public dynamic var statusInt: Int = 0
    @objc public dynamic var primaryKey: String = "primary"
    override public static func primaryKey() -> String? {
        return "primaryKey"
    }
}

public class UUIDData: Object {
    @objc public dynamic var uuid: String = ""
    @objc public dynamic var primaryKey: String = "primary"
    override public static func primaryKey() -> String? {
        return "primaryKey"
    }
}

public protocol IDStringToDate: NSObject {
    var createdID: String? { get }
}

public extension IDStringToDate {
    func getIDDate() -> Date? {
        guard let idString = createdID else { return nil }
        return DateUtil.full.formatter.date(from: idString)
    }
}
